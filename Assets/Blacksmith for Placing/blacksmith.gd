extends Node3D

@onready var raycasts = [$Cube_340/Ray1, $Cube_340/Ray2, $Cube_340/Ray3, $Cube_340/Ray4]
@export var meshes : Array[MeshInstance3D]
@onready var area = $Cube_340/Area3D
@onready var green_mat = preload("res://Assets/Blacksmith for Placing/placement_green.tres")
@onready var red_mat = preload("res://Assets/Blacksmith for Placing/placement_red.tres")


func check_placement() -> bool:
	for ray in raycasts:
		if !ray.is_colliding():
			placement_red()
			return false
	if area.get_overlapping_areas():
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
