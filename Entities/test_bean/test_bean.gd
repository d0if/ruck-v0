extends RigidBody3D

var angle_look: Vector2 = Vector2(0.0, 0.0)
var move_speed: float = 10.0 #units/sec target
var move_speed_target: float = 10.0

const MOVE_SPEED_WALK = 10.0
const MOVE_SPEED_SPRINT = 14.0
const MOVE_SPEED_CROUCH = 4.0
const MOVE_SPEED_CROUCHSPRINT = 8.0
const MOVE_SPEED_CROUCHSLIDE = 17.0

const CROUCH_SLIDE_THRESHOLD = 6.0 #how fast in order to start crouchslide

@onready var jump_collider = $JumpReset
@onready var stand_collider = $StandUp
var min_contact_pitch: float = 0.0
var contact_norm_2d: Vector2 = Vector2(1.0, 0.0) #no target_vel towards walls
var contact_norm_3d: Vector3 = Vector3(0.0, 1.0, 0.0) #contact norm from min_contact_pitch
const MAX_JUMP_ANGLE_RADS = 1.05*(PI/4.0) #limit of slopes that can be jumped on
const MAX_CLIMB_ANGLE_RADS = 1.05*(PI/4.0)
var holding_jump: bool = false
var crouch_sliding: bool = false
var crouchslide_jumping: bool = false
var short: bool = false

@onready var rucker = $RuckerModel
@onready var rucker_model = $RuckerModel/Armature
@onready var cam_origin = $CameraOrigin

@onready var stand_hitbox = $CollisionStand
@onready var crouch_hitbox = $CollisionCrouch
signal height_changed(is_short: bool)
signal mvt_speed_changed(new_speed: float)

var mvt_style_old: StringName = "RESET"
signal mvt_style_changed(new_anim: StringName)

@onready var Footsteps = $RuckerModel/Footsteps
@onready var floor_ray = $"RuckerModel/Floor ray"


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	angle_look = Global.angle_look
	if cam_origin: cam_origin.rotation.y = - angle_look.x
	if InputUtils.is_pressing_any_movement_key(): #only sync rotation if moving
		if rucker: rucker.rotation.y = MathUtils.approach_angle(rucker.rotation.y, PI - angle_look.x, delta * 10)
	#Global.debug("angle_look", angle_look)
	update_animation_state()
	mvt_speed_changed.emit(move_speed_target + self.linear_velocity.length())
	DebugUtils.f3_main("move speed target", move_speed_target)
	DebugUtils.f3_main("actual move speed", self.linear_velocity.length())

func _physics_process(delta: float) -> void:
	
	#alter walk speed based on movement type
	if Input.is_action_pressed("game_sprint"):
		if Input.is_action_pressed("game_crouch"):
			move_speed_target = MOVE_SPEED_CROUCHSPRINT
		else:
			move_speed_target = MOVE_SPEED_SPRINT
	else:
		if Input.is_action_pressed("game_crouch"):
			move_speed_target = MOVE_SPEED_CROUCH
		else:
			move_speed_target = MOVE_SPEED_WALK
	DebugUtils.f3_phys("mv speed", move_speed_target)
	if not (crouch_sliding or crouchslide_jumping):
		move_speed = move_speed + 0.1 * (move_speed_target - move_speed)
	#else: #only decay move speed if going uphill
		#move_speed = move_speed * 0.997
	
	#Global.debug_phys("move_speed", move_speed)
	
	if holding_jump:
		if not Input.is_action_pressed("game_jump"):
			holding_jump = false
			crouchslide_jumping = false #all csj's are holding_jumps but not viceversa so ok to not check above
		else:
			if self.linear_velocity.y > 0:
				#anti-gravity
				self.apply_central_impulse(Vector3(0.0, self.mass * self.gravity_scale * 0.02, 0.0))
	
	if Input.is_action_pressed("game_crouch"):
		if not short:
			height_changed.emit(true) #change height to short
		if self.linear_velocity.y < 0:
			if self.get_contact_count() == 0:
				if not crouchslide_jumping:
					#extra gravity
					self.apply_central_impulse(Vector3(0.0, -self.mass * self.gravity_scale * 0.05, 0.0))
			
			#try to start sliding
			if not crouch_sliding:
				if self.linear_velocity.length_squared() > CROUCH_SLIDE_THRESHOLD * CROUCH_SLIDE_THRESHOLD:
					if jump_collider.has_overlapping_bodies():
						crouch_sliding = true
						move_speed = min(self.linear_velocity.length() * 1.2, MOVE_SPEED_CROUCHSLIDE)
						self.physics_material_override.friction = 0.0
	
	else: #not holding crouch, try to get tall
		if not stand_collider.has_overlapping_bodies():
			height_changed.emit(false) #change height to tall
	
	#must pass all these conditions to continue a crouchslide
	var ok_to_crouchslide = false
	if Input.is_action_pressed("game_crouch") and Input.is_action_pressed("game_forward"):
		if jump_collider.has_overlapping_bodies():
			if self.linear_velocity.length_squared() > CROUCH_SLIDE_THRESHOLD * CROUCH_SLIDE_THRESHOLD:
				ok_to_crouchslide = true
		
	if not ok_to_crouchslide:
		crouch_sliding = false
		self.physics_material_override.friction = 0.5

	#Global.debug_phys("crouch_sliding", crouch_sliding)
	
	var vel_target_2d = InputUtils.get_horizontal_movement_from_keyboard()
	if crouch_sliding: vel_target_2d = Vector2(0.0, 1.0) #ignore left/right/back when cs
	vel_target_2d = vel_target_2d * move_speed
	
	var vel_target_3d = Vector3(vel_target_2d.x, self.linear_velocity.y, -vel_target_2d.y)
	vel_target_3d = vel_target_3d.rotated(Vector3(0.0, 1.0, 0.0), -angle_look.x)
	
	var vel_error_3d = vel_target_3d - self.linear_velocity
	var dot = Vector2(vel_error_3d.x, vel_error_3d.z).dot(contact_norm_2d)
	
	if self.get_contact_count() > 0 and dot < 0: #if velocity is going into the slope:
		#diminish crouchslide speed
		if crouch_sliding and self.linear_velocity.y > 0:
			move_speed = move_speed * 0.99
		if min_contact_pitch > MAX_CLIMB_ANGLE_RADS: #slope is steep,
			#cancel out towards-slope velocity
			vel_error_3d.x = vel_error_3d.x - dot * contact_norm_2d.x
			vel_error_3d.z = vel_error_3d.z - dot * contact_norm_2d.y
		else: #slope is gentle,
			#make movement in-plane to avoid stutter
			vel_error_3d = vel_error_3d - vel_error_3d.dot(contact_norm_3d) * contact_norm_3d
			#apply movement bonus
			vel_error_3d = vel_error_3d * (1.0 + 2.0 * min_contact_pitch)
	
	#just for viewing walk speed in debug
	Global.angle_walk = Vector2(self.linear_velocity.x, self.linear_velocity.z)
	
	#stop crouchslide_jumping after you land
	if jump_collider.has_overlapping_bodies() and self.linear_velocity.y < 0:
		crouchslide_jumping = false

	#Press jump button, jump collider is in the ground, & you're touching a <45deg slope
	if Input.is_action_just_pressed("game_jump") and (jump_collider.has_overlapping_bodies()) and (min_contact_pitch < MAX_JUMP_ANGLE_RADS):
			
		var jump_impulse = Vector3(0.0, 4 * self.mass * self.gravity_scale, 0.0)
		#jump is normal to slope
		var jump_impulse_normal = jump_impulse.dot(contact_norm_3d) * contact_norm_3d
		self.apply_central_impulse(jump_impulse_normal)
		holding_jump = true
		if crouch_sliding:
			var linear_velocity_norm = Vector3(self.linear_velocity.x, 0.0, self.linear_velocity.z).normalized()
			linear_velocity_norm = linear_velocity_norm.rotated(self.linear_velocity.cross(contact_norm_3d), PI/4.0)
			var jump_impulse_with = jump_impulse.dot(linear_velocity_norm) * linear_velocity_norm
			self.apply_central_impulse(jump_impulse_with)
			crouchslide_jumping = true
			move_speed = self.linear_velocity.length() * 1.05
	
		
	#Global.debug_phys("cs_jumping", crouchslide_jumping)
	
	#slow down quicker if hands are off WASD (maybe get rid of this)
	var impulse_scale_rate = 10.0 if (vel_target_2d.length_squared() == 0.0) else 5.0
	#worse air control
	if not jump_collider.has_overlapping_bodies():
		impulse_scale_rate = impulse_scale_rate * 0.5
	self.apply_central_impulse(impulse_scale_rate * vel_error_3d * delta * self.mass)
	#Global.debug_phys("linear_velocity", self.linear_velocity)

#get rid of motion on slopes & get contact info for elsewhere
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		min_contact_pitch = 999.0
		for contact_idx in range(0, state.get_contact_count()):
			var norm = state.get_contact_local_normal(contact_idx)
			var test_pitch = abs(Vector3(0.0, 1.0, 0.0).angle_to(norm))
			if min_contact_pitch > test_pitch:
				contact_norm_2d = Vector2(norm.x, norm.z).normalized()
				contact_norm_3d = norm
				min_contact_pitch = test_pitch
	
	#stop slope motion if not pressing keyboard
	if InputUtils.get_horizontal_movement_from_keyboard().length_squared() == 0.0:
		if min_contact_pitch < MAX_CLIMB_ANGLE_RADS:
			if state.linear_velocity.length_squared() < 0.1:
				state.set_linear_velocity(Vector3(0.0, state.linear_velocity.y, 0.0))




func _unhandled_input(event: InputEvent) -> void:
	pass


func _on_height_changed(is_short: bool) -> void:
	short = is_short
	stand_hitbox.disabled = is_short
	crouch_hitbox.disabled = not is_short

func update_animation_state() -> void:
	#possible movement (animation) states:
	#idle, walk_front/back/left/right, crouched, crouch_front (no back/left/right yet),
	#x, flying, x, run_front/back (no left/right yet), sliding
	var mvt_style = "UNSET"
	if self.linear_velocity.length_squared() <= 0.5: 
		#idle if no movement & not crouching
		mvt_style = "idle"
		if short:
			#no mvt & crouching
			mvt_style = "crouched"
	#else: #can now overwrite slow movement. fixes bug where you wiggle arms at apex of jump
	if (self.get_contact_count() == 0 and (not jump_collider.has_overlapping_bodies())) or self.min_contact_pitch > MAX_CLIMB_ANGLE_RADS: #airborne
		mvt_style = "flying"
	else: #touching the ground for real
		if crouch_sliding:
			mvt_style = "sliding" #only 1 slide direction
		elif InputUtils.get_horizontal_movement_from_keyboard().length_squared() == 0.0: #NEEDS GENERALIZED FOR NPCS
			mvt_style = "idle"
			if short:
				mvt_style = "crouched"
		else:
			#get move direction
			var front_dot = Vector2(0.0, -1.0).rotated(angle_look.x).dot(Vector2(self.linear_velocity.x, self.linear_velocity.z))
			var side_dot = Vector2(0.0, -1.0).rotated(angle_look.x + PI/2.0).dot(Vector2(self.linear_velocity.x, self.linear_velocity.z))
			if Input.is_action_pressed("game_sprint"): #NEEDS GENERALIZED FOR ACCESS/COMPAT FOR NPC RUCKERS
				if side_dot > 2:
					mvt_style = "run_right"
				if side_dot < -2:
					mvt_style = "run_left"
				if front_dot < -2:
					mvt_style = "run_back"
				if front_dot > 2:
					mvt_style = "run_front"
			elif short:
				if front_dot < 0:
					mvt_style = "crouch_back"
				else:
					mvt_style = "crouch_front"
			else:
				#forward/backwards walking needs to override any strafing
				if side_dot > 2:
					mvt_style = "walk_right"
				if side_dot < -2:
					mvt_style = "walk_left"
				if front_dot < -2:
					mvt_style = "walk_back"
				if front_dot > 2:
					mvt_style = "walk_front"
		
	#quick fix for sliding
	if crouch_sliding:
		if rucker_model: rucker_model.rotation.x += 0.1 * ( min_contact_pitch * sign(self.linear_velocity.y) * -1
				+ PI/2.0 - rucker_model.rotation.x ) 
	else:
		if rucker_model: rucker_model.rotation.x = 0 + PI/2.0
	#figure_out_animation_state
	#if animation_state != old_animation_state:
	if mvt_style != mvt_style_old:
		if mvt_style != "UNSET":
			mvt_style_changed.emit(mvt_style)
	mvt_style_old = mvt_style

func play_step_sounds():
	#if floor_ray. is_colliding():
		#var collider = floor_ray.get_collider()
		#if collider.is_in_group("grass"):
			Footsteps.play
		
