extends Control

@onready var blacksmith = preload("res://Assets/Blacksmith for Placing/blacksmith.tscn")

var camera
var instance
var placing = false
var range = 1000
var can_place = false
var current_rotation_y = 0.0
var rotation_speed = 90.0  # degrees per second

@onready var item_list = $ItemList

func _ready():
	camera = get_viewport().get_camera_3d()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and can_place:
		placing = false
		can_place = false
		instance.placed()

		# Enable collision after placing
		var shape = instance.get_node("Cube_340/StaticBody3D_1/CollisionShape3D_1")
		if shape:
			shape.disabled = false

		item_list.deselect_all()

	elif event.is_action_pressed("deselect") and placing:
		print("Placement canceled via 'deselect'.")
		placing = false
		can_place = false
		instance.queue_free()
		item_list.deselect_all()

func _process(delta: float) -> void:
	if placing:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			instance.transform.origin = collision.position
			can_place = instance.check_placement()

		# Smooth freeform rotation while holding Q or E
		if Input.is_action_pressed("rotate_left"):
			current_rotation_y -= rotation_speed * delta
		if Input.is_action_pressed("rotate_right"):
			current_rotation_y += rotation_speed * delta

		instance.rotation.y = deg_to_rad(current_rotation_y)

func _on_item_list_item_selected(index: int) -> void:
	if placing:
		instance.queue_free()

	if index == 0:
		instance = blacksmith.instantiate()

		# Disable collision before placement
		var shape = instance.get_node("Cube_340/StaticBody3D_1/CollisionShape3D_1")
		if shape:
			shape.disabled = true

		current_rotation_y = 0.0  # Reset rotation when placing a new building
		placing = true
		get_parent().add_child(instance)
