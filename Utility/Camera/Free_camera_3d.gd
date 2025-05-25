extends Camera3D

@export var selection_box: ColorRect  # Drag box in a CanvasLayer

var is_dragging := false
var drag_start := Vector2()
var selectable_nodes := []
var hovered_nodes := []

func _ready():
	selectable_nodes = get_tree().get_nodes_in_group("Selectable")
	selection_box.visible = false

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start dragging
			is_dragging = true
			drag_start = event.position
			selection_box.position = drag_start
			selection_box.size = Vector2.ZERO
			selection_box.visible = true

			# Deselect all currently selected nodes
			for node in selectable_nodes:
				if node.is_in_group("Selected"):
					node.remove_from_group("Selected")
		else:
			# End dragging
			is_dragging = false
			selection_box.visible = false

			var rect = Rect2(selection_box.position, selection_box.size).abs()

			for node in selectable_nodes:
				if not node is Node3D:
					continue
				var screen_pos = unproject_position(node.global_transform.origin)
				if rect.has_point(screen_pos):
					if not node.is_in_group("Selected"):
						node.add_to_group("Selected")
						print("Selected: ", node.name)

			# Clear hover group
			for node in hovered_nodes:
				if node.is_in_group("Hover"):
					node.remove_from_group("Hover")
			hovered_nodes.clear()

func _process(delta):
	if is_dragging:
		var drag_end = get_viewport().get_mouse_position()
		var rect_pos = Vector2(
			min(drag_start.x, drag_end.x),
			min(drag_start.y, drag_end.y)
		)
		var rect_size = Vector2(
			abs(drag_end.x - drag_start.x),
			abs(drag_end.y - drag_start.y)
		)

		selection_box.position = rect_pos
		selection_box.size = rect_size

		var rect = Rect2(rect_pos, rect_size)

		for node in selectable_nodes:
			if not node is Node3D:
				continue
			var screen_pos = unproject_position(node.global_transform.origin)
			if rect.has_point(screen_pos):
				if not node.is_in_group("Hover"):
					node.add_to_group("Hover")
					hovered_nodes.append(node)
			else:
				if node.is_in_group("Hover"):
					node.remove_from_group("Hover")
					hovered_nodes.erase(node)
