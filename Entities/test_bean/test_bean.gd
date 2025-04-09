extends RigidBody3D

var angle_look: Vector2 = Vector2(0.0, 0.0)


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("game_jump"):
		self.apply_central_impulse(Vector3(0.0, 5 * self.mass, 0.0))
	
func _unhandled_input(event: InputEvent) -> void:
	pass
