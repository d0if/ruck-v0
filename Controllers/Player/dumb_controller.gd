extends "res://Controllers/rigidbodycontroller.gd"

func _process(delta: float) -> void:
	DebugUtils.f3_main("min contact pitch test", self.min_contact_pitch)
