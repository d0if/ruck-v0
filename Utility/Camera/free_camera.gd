extends RigidBody3D

@onready var yaw = $Yaw
@onready var pitch = $Yaw/Pitch
@onready var sway = $Yaw/Pitch/Sway
@onready var camera = $Yaw/Pitch/Sway/Camera3D

@onready var rayend = $Rayend
var target_height: float = 10.0 #relative to the ground
var ray_length: float = 0.0 #
var position_2d: Vector2 = Vector2(0.0, 0.0) #probably global position?
var height_pid: PID = PID.new(0.2, 0.1, 0.1) #applies forces based on height difference

func _ready() -> void:
	CameraUtils.zoom_level_changed.connect(_handle_zoom_change)
	_handle_zoom_change(CameraUtils.zoom_level, CameraUtils.zoom_level_old)

func _process(delta: float) -> void:
	yaw.rotation.y = -CameraUtils.angle_look.x
	pitch.rotation.x = -CameraUtils.angle_look.y
	


func _physics_process(delta: float) -> void:
	#raycast to find floor height
	if CameraUtils.zoom_level == CameraUtils.ZOOM_FREE:
		#raycast from origin to intended camera position & get available length
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(self.global_position, rayend.global_position)
		query.set_hit_from_inside(true)
		query.set_collision_mask(0b00000000_00000000_00000000_00000010) #only collide with layer 2
		var result = space_state.intersect_ray(query)
		var ray_colliding = not result.is_empty()
		if ray_colliding:
			ray_length = (self.global_position - result["position"]).y
		else:
			ray_length = 0.0
			
		#controls
		#vertical adjustment
		self.apply_central_impulse(Vector3(0.0, 0.1 * height_pid.update(target_height - ray_length, delta), 0.0))
		
		#horizontal adjustment
		var vel_2d = 0.1 * InputUtils.get_horizontal_movement_from_keyboard()
		vel_2d.y = -vel_2d.y
		self.apply_central_impulse(Vector3(vel_2d.x, 0.0, vel_2d.y).rotated(Vector3(0.0, 1.0, 0.0), -CameraUtils.angle_look.x))

func _handle_zoom_change(zoom_level, zoom_level_old):
	if zoom_level == CameraUtils.ZOOM_FREE: #only activate camera if in freecam mode
		camera.make_current()
