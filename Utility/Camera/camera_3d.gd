extends Camera3D

@export var selectray: RayCast3D

func _process(_delta):
	if Input.is_action_just_pressed("selection"):
		if selectray.is_colliding():
			var hit = selectray.get_collider()
			if hit.is_in_group("Selectable"):
				print("Selected: ", hit.name)
				print("Groups: ", hit.get_groups())
				hit.add_to_group("Selected")
			else:
				print("Hit something, but it's not a Rucker.")
		else:
			print("Nothing hit.")
