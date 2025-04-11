extends RigidBody3D

var angle_look: Vector2 = Vector2(0.0, 0.0)
var move_speed: float = 10.0 #units/sec target
var move_speed_target: float = 10.0

const MOVE_SPEED_WALK = 10.0
const MOVE_SPEED_SPRINT = 14.0
const MOVE_SPEED_CROUCH = 4.0

var vel_target_2d: Vector2 = Vector2(0.0, 0.0) #x is right/left, y is front/back

@onready var jump_collider = $JumpReset
var min_contact_pitch: float = 0.0
var contact_norm_2d: Vector2 = Vector2(1.0, 0.0) #no target_vel towards walls
var contact_norm_3d: Vector3 = Vector3(0.0, 1.0, 0.0)
const MAX_JUMP_ANGLE_RADS = 1.05*(PI/4.0) #limit of slopes that can be jumped on
const MAX_CLIMB_ANGLE_RADS = 1.05*(PI/4.0)
var holding_jump: bool = false

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	angle_look = Global.angle_look

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("game_sprint"):
		move_speed_target = MOVE_SPEED_SPRINT
	elif Input.is_action_pressed("game_crouch"):
		move_speed_target = MOVE_SPEED_CROUCH
	else:
		move_speed_target = MOVE_SPEED_WALK
	
	move_speed = move_speed + 0.1 * (move_speed_target - move_speed)

	
	if holding_jump:
		if not Input.is_action_pressed("game_jump"):
			holding_jump = false
		else:
			if self.linear_velocity.y > 0:
				#anti-gravity
				self.apply_central_impulse(Vector3(0.0, 0.5, 0.0))
	
	#Press jump button, jump collider is in the ground, & you're touching a <45deg slope
	if Input.is_action_just_pressed("game_jump") and (jump_collider.has_overlapping_bodies()) and (min_contact_pitch < MAX_JUMP_ANGLE_RADS):
		var jump_impulse = Vector3(0.0, 4 * self.mass * self.gravity_scale, 0.0)
		#jump is normal to slope
		jump_impulse = jump_impulse.dot(contact_norm_3d) * contact_norm_3d
		self.apply_central_impulse(jump_impulse)
		holding_jump = true
	
	vel_target_2d = Global.get_horizontal_movement_from_keyboard()
	vel_target_2d = vel_target_2d * move_speed
	
	var vel_target_3d = Vector3(vel_target_2d.x, self.linear_velocity.y, -vel_target_2d.y)
	vel_target_3d = vel_target_3d.rotated(Vector3(0.0, 1.0, 0.0), -angle_look.x)
	
	var vel_error_3d = vel_target_3d - self.linear_velocity
	var dot = Vector2(vel_error_3d.x, vel_error_3d.z).dot(contact_norm_2d)
	
	if self.get_contact_count() > 0 and dot < 0: #if velocity is going into the slope:
		if min_contact_pitch > MAX_CLIMB_ANGLE_RADS: #slope is steep,
			#cancel out towards-slope velocity
			vel_error_3d.x = vel_error_3d.x - dot * contact_norm_2d.x
			vel_error_3d.z = vel_error_3d.z - dot * contact_norm_2d.y
		else: #slope is gentle, apply movement bonus
			#make movement in-plane to avoid stutter
			vel_error_3d = vel_error_3d - vel_error_3d.dot(contact_norm_3d) * contact_norm_3d
			#apply movement bonus
			vel_error_3d = vel_error_3d * (1.0 + 2.0 * min_contact_pitch)
	
	#just for viewing walk speed in debug
	Global.angle_walk = Vector2(self.linear_velocity.x, self.linear_velocity.z)
	
	#slow down quicker if hands are off keyboard (maybe get rid of this)
	var impulse_scale_rate = 10.0 if (vel_target_2d.length_squared() == 0.0) else 5.0
	#worse air control
	if not jump_collider.has_overlapping_bodies():
		impulse_scale_rate = impulse_scale_rate * 0.5
	self.apply_central_impulse(impulse_scale_rate * vel_error_3d * delta * self.mass)
	#self.apply_central_impulse(movement_pid.update(vel_error_3d * delta * self.mass, delta))

#get rid of motion on slopes & get contact info for elsewhere
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#contact_norm_2d = Vector2(1.0, 0.0)
	#contact_norm_3d = Vector3(0.0, 1.0, 0.0)
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
	if Global.get_horizontal_movement_from_keyboard().length_squared() == 0.0:
		if min_contact_pitch < MAX_CLIMB_ANGLE_RADS:
			if state.linear_velocity.length_squared() < 0.1:
				state.set_linear_velocity(Vector3(0.0, state.linear_velocity.y, 0.0))




func _unhandled_input(event: InputEvent) -> void:
	pass
