extends Area3D

@export var outline: MeshInstance3D
func _process(delta: float) -> void:
	if self.is_in_group("Selected"):
		outline.material_overlay.set_shader_parameter("outline_width", 5.4)
	else:
		outline.material_overlay.set_shader_parameter("outline_width", 0)
	
