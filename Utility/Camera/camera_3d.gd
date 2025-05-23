extends Camera3D

@export var selectray: RayCast3D
var firstobject: Node = null
var current_mode: String = ""
var interacted_this_hold := {}

func _process(_delta):
	# Clear hold tracking when key is first pressed
	if Input.is_action_just_pressed("selection"):
		interacted_this_hold.clear()
		firstobject = null

	# While holding the key, update mode based on what you're looking at and select/deselect accordingly
	if Input.is_action_pressed("selection"):
		# Update current_mode based on raycast target at this moment
		if selectray.is_colliding():
			var hit = selectray.get_collider()

			if hit.is_in_group("Selected"):
				current_mode = "deselect"
			elif hit.is_in_group("Selectable"):
				current_mode = "select"
			else:
				current_mode = ""
		else:
			current_mode = ""

		# Perform selection/deselection if mode is set
		if current_mode != "":
			if selectray.is_colliding():
				var hit = selectray.get_collider()

				if hit.is_in_group("Selectable"):
					if not interacted_this_hold.has(hit):
						interacted_this_hold[hit] = true

						if current_mode == "select" and not hit.is_in_group("Selected"):
							hit.add_to_group("Selected")
							print("Selected: ", hit.name)

						elif current_mode == "deselect" and hit.is_in_group("Selected"):
							hit.remove_from_group("Selected")
							print("Deselected: ", hit.name)

	# Clear mode and interaction tracking when key is released
	if Input.is_action_just_released("selection"):
		current_mode = ""
		interacted_this_hold.clear()
		firstobject = null
