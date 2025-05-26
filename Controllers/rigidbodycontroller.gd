extends CharacterBody3D
class_name RigidBodyController

@export var ANGLE_VELOCITY_PUNISHMENT: Curve

var target_velocity: Vector3 = Vector3(0.0, 0.0, 0.0)

var ignore_axis: Vector3 = Vector3(0.0, 1.0, 0.0) #set to 0,0,0 to ignore nothing


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	target_velocity.y = -1.0
	velocity = target_velocity
	move_and_slide()
	
