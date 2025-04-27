extends Node3D

const ANGLE_SPRING: float = (PI/2.0)*(5.0/6.0)
const ANGLE_MAX: float = ANGLE_SPRING * 2.0

var target_fov: float = 75.0

const WALK_HEIGHT = 0.0
const CROUCH_HEIGHT = -0.5

var height_tween: Tween

@onready var yaw = $Gimbal
@onready var pitch = $Gimbal/Pitch
@onready var camera = $Gimbal/Pitch/Camera
@onready var rayend = $Gimbal/Pitch/Node3D
var ray_colliding: bool = false
var ray_length: float = 1.75

var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enabled:
		#update fov
		camera.fov += 10 * delta * (target_fov - camera.fov)
		
		#raycast is getting shot in physics_process, leaving ray length
		if ray_colliding:
			camera.position.z = ray_length
		else:
			camera.position.z += 20 * delta * (1.75 + CameraUtils.zoom_float - camera.position.z)
		
		camera_spring(delta)
		
		if pitch: pitch.rotation.x = -CameraUtils.angle_look.y
	pass

func _physics_process(delta: float) -> void:
	#raycast from origin to intended camera position & get available length
	rayend.position.z = 1.75 + CameraUtils.zoom_float + 2.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(self.global_position, rayend.global_position)
	query.set_hit_from_inside(true)
	query.set_collision_mask(0b00000000_00000000_00000000_00000001) #only collide with layer 1
	var result = space_state.intersect_ray(query)
	ray_colliding = not result.is_empty()
	if ray_colliding:
		ray_length = (self.global_position - result["position"]).length() - 0.05
		#iterate through & find the shortest length
	else:
		ray_length = 1.75 + CameraUtils.zoom_float
	ray_length = min(ray_length, 1.75 + CameraUtils.zoom_float)
	#raycast.target_position.z = 1.75 + CameraUtils.zoom_float
	#if raycast.get_collision_point() != Vector3(0, 0, 0):
		#var length = (raycast.position - raycast.get_collision_point()).length()
		#DebugUtils.f3_main("hit location", raycast.get_collision_point())
		#camera.position.z += 20 * delta * (length - camera.position.z)
	#else:
		#camera.position.z += 20 * delta * (1.75 + CameraUtils.zoom_float - camera.position.z)


#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#CameraUtils.angle_look.x = CameraUtils.angle_look.x + event.screen_relative.x * Global.settings.get_value("mouse", "sensitivity").x
		#CameraUtils.angle_look.y = CameraUtils.angle_look.y + event.screen_relative.y * Global.settings.get_value("mouse", "sensitivity").y
	#elif event is InputEventJoypadMotion:
		#pass
	
	#CameraUtils.angle_look.x = MathUtils.cap_radians(CameraUtils.angle_look.x)

func camera_spring(delta: float) -> void:
	CameraUtils.angle_look.y = MathUtils.cap_above_ease(CameraUtils.angle_look.y, ANGLE_SPRING, 1.0/(1+10*delta))
	CameraUtils.angle_look.y = MathUtils.cap_below_ease(CameraUtils.angle_look.y,-ANGLE_SPRING, 1.0/(1+10*delta))
	CameraUtils.angle_look.y = MathUtils.cap_above(CameraUtils.angle_look.y, ANGLE_MAX)
	CameraUtils.angle_look.y = MathUtils.cap_below(CameraUtils.angle_look.y, -ANGLE_MAX)


func _on_test_bean_height_changed(is_short: bool) -> void:
	if height_tween:
		height_tween.kill()
	
	height_tween = create_tween()
	var new_location = CROUCH_HEIGHT if is_short else WALK_HEIGHT
	height_tween.tween_property(yaw, "position:y", new_location, 0.1)


func _on_test_rucker_mvt_speed_changed(new_speed: float) -> void:
	target_fov = 75.0 + 2*sqrt(new_speed) - 10
