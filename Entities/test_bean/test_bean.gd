extends RigidBody3D

var angle_look: Vector2 = Vector2(0.0, 0.0)
var move_speed: float = 10.0 #units/sec target

var vel_target_2d: Vector2 = Vector2(0.0, 0.0) #x is right/left, y is front/back

@onready var jump_collider = $JumpReset
var min_contact_pitch: float = 0.0
var contact_norm_2d: Vector2 = Vector2(1.0, 0.0) #no target_vel towards walls
const MAX_JUMP_ANGLE_RADS = 1.05*(PI/4.0)

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	angle_look = Global.angle_look

func _physics_process(delta: float) -> void:
	#Press jump button, jump collider is in the ground, & you're touching a <45deg slope
	if Input.is_action_just_pressed("game_jump") and (jump_collider.has_overlapping_bodies()) and (min_contact_pitch < MAX_JUMP_ANGLE_RADS):
		self.apply_central_impulse(Vector3(0.0, 5 * self.mass * self.gravity_scale, 0.0))
		
	vel_target_2d = Global.get_horizontal_movement_from_keyboard()
	vel_target_2d = vel_target_2d * move_speed
	
	var vel_target_3d = Vector3(vel_target_2d.x, self.linear_velocity.y, -vel_target_2d.y)
	vel_target_3d = vel_target_3d.rotated(Vector3(0.0, 1.0, 0.0), -angle_look.x)
	
	var vel_error_3d = vel_target_3d - self.linear_velocity
	if min_contact_pitch > MAX_JUMP_ANGLE_RADS: #cancel out target vel towards walls
		var dot = Vector2(vel_error_3d.x, vel_error_3d.z).dot(contact_norm_2d)
		if dot < 0:
			#dot product between contact normal & trial velocity only negative if towards
			vel_error_3d.x = vel_error_3d.x - dot * contact_norm_2d.x
			vel_error_3d.z = vel_error_3d.z - dot * contact_norm_2d.y
	Global.angle_walk = Vector2(self.linear_velocity.x, self.linear_velocity.z)
	self.apply_central_impulse(5.0 * vel_error_3d * delta * self.mass)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	min_contact_pitch = 0.0
	contact_norm_2d = Vector2(1.0, 0.0)
	if state.get_contact_count() > 0:
		min_contact_pitch = 999.0
		for contact_idx in range(0, state.get_contact_count()):
			var norm = state.get_contact_local_normal(contact_idx)
			var test_pitch = abs(Vector3(0.0, 1.0, 0.0).angle_to(norm))
			if min_contact_pitch > test_pitch:
				contact_norm_2d = Vector2(norm.x, norm.z).normalized()
				min_contact_pitch = test_pitch
		

func _unhandled_input(event: InputEvent) -> void:
	pass


#func _on_jump_reset_body_entered(body: Node3D) -> void:
	#can_jump = true
	#pass # Replace with function body.
