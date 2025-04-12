extends Node3D

@onready var animator = $AnimationPlayer

func _ready() -> void:
	animator.animation_set_next("Jump", "Fall")

func _on_test_rucker_mvt_anim_changed(new_anim: StringName) -> void:
	animator.current_animation = new_anim
	pass # Replace with function body.
