extends RigidBody3D
class_name RigidBodyController

@export var MAX_ANGLE_WALK: float = 0.0
@export var MAX_ANGLE_JUMP: float = 0.0
@export var MIN_ANGLE_SLIDE: float = 0.0
var min_contact_pitch: float = 0.0
var min_contact_norm_2d: Vector2 = Vector2(0.0,0.0)
var min_contact_norm_3d: Vector3 = Vector3(0.0,0.0,0.0)
var max_contact_pitch: float = 0.0
var max_contact_norm_2d: Vector2 = Vector2(0.0,0.0)
var max_contact_norm_3d: Vector3 = Vector3(0.0,0.0,0.0)

@export var ANGLE_VELOCITY_PUNISHMENT: Curve

#collect some info
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		min_contact_pitch = 999.0
		max_contact_pitch = 0.0
		for contact_idx in range(0, state.get_contact_count()):
			var norm = state.get_contact_local_normal(contact_idx)
			var test_pitch = abs(Vector3(0.0, 1.0, 0.0).angle_to(norm))
			if min_contact_pitch > test_pitch:
				min_contact_norm_2d = Vector2(norm.x, norm.z).normalized()
				min_contact_norm_3d = norm
				min_contact_pitch = test_pitch
			if max_contact_pitch < test_pitch:
				max_contact_norm_2d = Vector2(norm.x, norm.z).normalized()
				max_contact_norm_3d = norm
				max_contact_pitch = test_pitch

func _physics_process(delta: float) -> void:
	pass
