extends "res://Controllers/rigidbodycontroller.gd"

var move_angle: float = 0.0

func _process(delta: float) -> void:
	move_angle = MathUtils.cap_radians(move_angle + delta / 2.0)
	#target_velocity = Vector3(1.0, 0.0, 0.0).rotated(Vector3(0.0,1.0,0.0),move_angle)
	target_velocity = Vector3(0.0, 0.0, 0.0)
	DebugUtils.f3_main("dumb controller move angle", move_angle)
