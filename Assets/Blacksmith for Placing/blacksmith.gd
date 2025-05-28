extends Node3D

@onready var raycasts = [$Raycasts/Ray1, $Raycasts/Ray2, $Raycasts/Ray3, $Raycasts/Ray4]
@export var raycast_container: Node
@export var ray_length: float
@export var meshes : Array[MeshInstance3D]
@onready var area = $Area3D
@onready var green_mat = preload("res://Assets/Blacksmith for Placing/placement_green.tres")
@onready var red_mat = preload("res://Assets/Blacksmith for Placing/placement_red.tres")


func check_placement() -> bool:
	#for ray in raycast_container.get_children():
		##ray origin from transform
		#var ray_origin: Vector3 = ray.global_position
		#var ray_end: Vector3 = ray_origin + Vector3(0.0, -ray_length, 0.0)
		#var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		#query.set_hit_from_inside(true)
		#query.collide_with_bodies = true
		#query.collide_with_areas = true
		#query.set_collision_mask(0b00000000_00000000_00000000_00000001) #only collide with layer 1
		#var result = Global.main_level.get_world_3d().direct_space_state.intersect_ray(query)
		#if result.is_empty():
			#DebugUtils.f3_main("placement failed due to", "RAYS")
			#placement_red()
			#return false
	#replaced with ^^^^
	for ray in raycasts:
		if !ray.is_colliding():
			placement_red()
			return false

	if area.get_overlapping_areas():
		DebugUtils.f3_main("placement failed due to", "AREA")
		placement_red()
		return false
	placement_green()
	return true


func placed() -> void:
	for mesh in meshes:
		mesh.material_override = null
	for ray in raycasts:
			ray.queue_free()

func placement_red() -> void:
	for mesh in meshes:
		mesh.material_override = red_mat


func placement_green() -> void:
	for mesh in meshes:
		mesh.material_override = green_mat
