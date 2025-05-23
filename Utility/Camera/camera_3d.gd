extends Camera3D

@export var selectray: RayCast3D
var current_mode: String = ""       # "select", "deselect", or ""
var interacted_this_hold := {}      # Track objects already acted on during hold
var hovered: Node = null

func _process(_delta):
	if selectray.is_colliding():
		var hit = selectray.get_collider()
		if hit.is_in_group("Selectable"):
			if hovered != hit:
				if hovered and hovered.is_in_group("Hover"):
					hovered.remove_from_group("Hover")
				hit.add_to_group("Hover")
				hovered = hit
		else:
			if hovered and hovered.is_in_group("Hover"):
				hovered.remove_from_group("Hover")
			hovered = null
	else:
		if hovered and hovered.is_in_group("Hover"):
			hovered.remove_from_group("Hover")
		hovered = null
	# On key press, determine mode based on what is hit
	if Input.is_action_just_pressed("selection"):
		interacted_this_hold.clear()
		current_mode = ""

		if selectray.is_colliding():
			var hit = selectray.get_collider()
			if hit.is_in_group("Selected"):
				current_mode = "deselect"
			elif hit.is_in_group("Selectable"):
				current_mode = "select"
			else:
				current_mode = "select"
		else:
			current_mode = "select"  # <<<<< Add this else here!

	# While holding, apply mode to every new selectable hit by raycast
	if Input.is_action_pressed("selection") and current_mode != "":
		if selectray.is_colliding():
			var hit = selectray.get_collider()

			if hit.is_in_group("Selectable") and not interacted_this_hold.has(hit):
				interacted_this_hold[hit] = true

				if current_mode == "select" and not hit.is_in_group("Selected"):
					hit.add_to_group("Selected")
					print("Selected: ", hit.name)
				elif current_mode == "deselect" and hit.is_in_group("Selected"):
					hit.remove_from_group("Selected")
					print("Deselected: ", hit.name)

	# Reset mode on key release
	if Input.is_action_just_released("selection"):
		current_mode = ""
		interacted_this_hold.clear()

	# Press X to clear all selections
	if Input.is_action_just_pressed("deselect"):
		var selected_nodes = get_tree().get_nodes_in_group("Selected")
		for node in selected_nodes:
			node.remove_from_group("Selected")
