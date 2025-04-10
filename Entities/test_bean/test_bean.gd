extends RigidBody3D

var angle_look: Vector2 = Vector2(0.0, 0.0)
var move_speed: float = 10.0 #units/sec target

var vel_target_2d: Vector2 = Vector2(0.0, 0.0) #x is right/left, y is front/back

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	angle_look = Global.angle_look

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("game_jump"):
		self.apply_central_impulse(Vector3(0.0, 5 * self.mass * self.gravity_scale, 0.0))
		
	vel_target_2d = Global.get_horizontal_movement_from_keyboard()
	vel_target_2d = vel_target_2d * move_speed
	
	var vel_target_3d = Vector3(vel_target_2d.x, self.linear_velocity.y, -vel_target_2d.y)
	vel_target_3d = vel_target_3d.rotated(Vector3(0.0, 1.0, 0.0), -angle_look.x)
	
	var vel_error_3d = vel_target_3d - self.linear_velocity
	Global.angle_walk = Vector2(self.linear_velocity.x, self.linear_velocity.z)
	self.apply_central_impulse(5.0 * vel_error_3d * delta * self.mass)
	
func _unhandled_input(event: InputEvent) -> void:
	pass
