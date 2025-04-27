extends Node3D

#var active: bool = true #instead of this, try to design UI that absorbs mouse input

#children
@onready var height = $Height
@onready var yaw = $Height/Yaw
@onready var pitch = $Height/Yaw/Pitch
@onready var dist = $Height/Yaw/Pitch/Distance
@onready var sway = $Height/Yaw/Pitch/Distance/Sway
@onready var freelook_yaw = $Height/Yaw/Pitch/Distance/Sway/FreeYaw
@onready var freelook_pitch = $Height/Yaw/Pitch/Distance/Sway/FreeYaw/FreePitch
@onready var camera = $Height/Yaw/Pitch/Distance/Sway/FreeYaw/FreePitch/Camera3D

@onready var vignette = $Height/Yaw/Pitch/Distance/Sway/FreeYaw/FreePitch/Camera3D/Vignette

@onready var rayend = $Height/Yaw/Pitch/RayEnd
var ray_colliding: bool = false
var ray_length: float = 0.0

const ANGLE_SPRING: float = (PI/2.0)*(5.0/6.0)
const ANGLE_MAX: float = ANGLE_SPRING * 2.0

var _sway_angle: Vector2 = Vector2(0.0, 0.0)
var sway_amplitude_target: Vector2 = Vector2(0.06, 0.1)
var _sway_amplitude: Vector2 = sway_amplitude_target
var sway_frequency: Vector2 = Vector2(0.3, 0.3508)
var sway_phase: Vector2 = Vector2(0.0, 0.0)
var sway_bounce: bool = false #y-sway will use abs(sin) when true (for running)
var _sway_invert: bool = false #for smooth transition from abs(sin) to sin

const CROUCH_HEIGHT = -0.5
const WALK_HEIGHT = 0.0
var height_tween: Tween

var target_fov: float = 75.0

####TODO
#Some controls to decide when camera is movable (e.g. not while in pause menu)
#View bobbing. abs(sin) for bounce?
#FOV effects
#toggle visibility mask for first/third person (can't see player in first person)

func _ready() -> void:
	CameraUtils.zoom_level_changed.connect(_handle_zoom_change)
	_handle_zoom_change(CameraUtils.zoom_level, CameraUtils.zoom_level_old) #initialize cull mask & other fps/tps stuff

func _process(delta: float) -> void:
	#camera springiness
	CameraUtils.camera_spring(delta, ANGLE_SPRING, -ANGLE_SPRING, ANGLE_MAX, -ANGLE_MAX)
	
	#sync yaw and pitch
	if yaw:		yaw.rotation.y = -CameraUtils.angle_look.x
	if pitch:	pitch.rotation.x = -CameraUtils.angle_look.y
	
	#update cam distance. note that the raycast (rayend) distance gets updated in _physics_process()
	#decide between first person and third person camera
	if CameraUtils.zoom_level == CameraUtils.ZOOM_TPS:
		dist.position.z = MathUtils.cap_above(MathUtils.approach_ease(dist.position.z, #current
					1.0 + CameraUtils.zoom_float, #target
					delta * 4.0), ray_length - 0.2) #easing rate, hard cap
		
	else:
		#dist.position.z = MathUtils.approach_ease(dist.position.z, 0.0, delta * 3.0)
		dist.position.z = 0.0
	
	#camera sway
	if sway:
		#change angle based on frequency
		_sway_angle += sway_frequency * delta * 2.0 * PI #frequency of 2 means 2 rotations/second this way
		_sway_angle.x = MathUtils.cap_radians(_sway_angle.x)
		_sway_angle.y = MathUtils.cap_radians(_sway_angle.y)
		
		#amplitude should approach target rather than jump directly to it
		_sway_amplitude.x = MathUtils.approach_ease(_sway_amplitude.x, sway_amplitude_target.x, delta * 10.0)
		_sway_amplitude.y = MathUtils.approach_ease(_sway_amplitude.y, sway_amplitude_target.y, delta * 10.0)
		
		#update actual sway
		sway.position.x = MathUtils.approach_line(sway.position.x, 
				_sway_amplitude.x * sin(_sway_angle.x + sway_phase.x), 
				delta / 0.15)
		if sway_bounce:
			sway.position.y = MathUtils.approach_line(sway.position.y,
					_sway_amplitude.y * abs(sin(_sway_angle.y + sway_phase.y)),
					delta / 0.15) #limit speed to 0.15 units/sec.
		else:
			sway.position.y = MathUtils.approach_line(sway.position.y, 
					(-1.0 if _sway_invert else 1.0) * _sway_amplitude.y * sin(_sway_angle.y + sway_phase.y), 
					delta / 0.15)
	
	#fov effects. also see _on_test_rucker_mvt_speed_changed()
	camera.fov = MathUtils.approach_ease(camera.fov, target_fov + 3.0 * CameraUtils.transition, 10.0 * delta)
	
	vignette.material.set_shader_parameter("vignette_strength", abs(CameraUtils.transition) / (CameraUtils.TRANSITION_MINIMUM_SCROLLS * CameraUtils.TRANSITION_TICK))
	
	if CameraUtils.zoom_level == CameraUtils.ZOOM_FPS or CameraUtils.zoom_level == CameraUtils.ZOOM_TPS:
		CameraUtils.global_cam_position = dist.global_position

func _physics_process(delta: float) -> void:
	#raycast collision when in third person mode
	if CameraUtils.zoom_level == CameraUtils.ZOOM_TPS:
		#raycast from origin to intended camera position & get available length
		rayend.position.z = 1.0 + CameraUtils.zoom_float + 2.0 #about == camera distance + 2.0

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(height.global_position, rayend.global_position)
		query.set_hit_from_inside(true)
		query.set_collision_mask(0b00000000_00000000_00000000_00000001) #only collide with layer 1
		var result = space_state.intersect_ray(query)
		ray_colliding = not result.is_empty()
		if ray_colliding:
			ray_length = (self.global_position - result["position"]).length() - 0.05
			#iterate through & find the shortest length
		else:
			ray_length = 1.0 + CameraUtils.zoom_float
		ray_length = min(ray_length, 1.0 + CameraUtils.zoom_float)

func _unhandled_input(event: InputEvent) -> void:
	if CameraUtils.zoom_level == CameraUtils.ZOOM_FPS or CameraUtils.zoom_level == CameraUtils.ZOOM_TPS:
		if event is InputEventMouseMotion:
			CameraUtils.angle_look.x = CameraUtils.angle_look.x + event.screen_relative.x * Global.settings.get_value("mouse", "sensitivity").x
			CameraUtils.angle_look.y = CameraUtils.angle_look.y + event.screen_relative.y * Global.settings.get_value("mouse", "sensitivity").y
		elif event is InputEventJoypadMotion:
			pass
		
		CameraUtils.angle_look.x = MathUtils.cap_radians(CameraUtils.angle_look.x)

func _handle_zoom_change(new_state, old_state) -> void:
	match new_state:
		CameraUtils.ZOOM_FPS, CameraUtils.ZOOM_TPS:
			dist.position.z = Vector3(height.global_position - CameraUtils.global_cam_position).length()
			camera.make_current()
			camera.set_cull_mask_value(3, new_state == CameraUtils.ZOOM_TPS) #player is on layer 3, hide it in fps
		_:
			pass

func _check_sway_invert() -> void:
	if sin(_sway_angle.y + sway_phase.y) < 0.0:
		_sway_invert = true
	else:
		_sway_invert = false

func _on_test_rucker_height_changed(is_short: bool) -> void:
	if height_tween:
		height_tween.kill()
	
	height_tween = create_tween()
	var new_location = CROUCH_HEIGHT if is_short else WALK_HEIGHT
	height_tween.tween_property(height, "position:y", new_location, 0.1)

func _on_test_rucker_mvt_speed_changed(new_speed: float) -> void:
	target_fov = 75.0 + 2*sqrt(new_speed) - 10

func _on_test_rucker_mvt_style_changed(new_anim: StringName, old_anim: StringName) -> void:
	#no view bobbing if we're in 3rd person. just a little bit of sway
	if CameraUtils.zoom_level == CameraUtils.ZOOM_TPS:
		sway_amplitude_target = Vector2(0.02, 0.06)
		sway_frequency = Vector2(0.381, 0.2)
		sway_bounce = false
		return
	
	#set view bobbing parameters
	_check_sway_invert()
	
	match new_anim:
		"idle":
			sway_amplitude_target = Vector2(0.01, 0.03)
			sway_frequency = Vector2(0.341, 0.2)
			sway_bounce = false
		"walk_front", "walk_back", "walk_left", "walk_right":
			#for a walk animation with 2 steps over .7666 sec, use (2step/.7666sec)/2 ~= 1.304
			#for y-frequency (halve it since abs(sin) bounces twice for each rotation)
			sway_amplitude_target = Vector2(0.0, 0.1)
			sway_frequency = Vector2(0.0, 1.304)
			sway_bounce = true
		"crouched":
			sway_amplitude_target = Vector2(0.01, 0.03)
			sway_frequency = Vector2(0.341, 0.2)
			sway_bounce = false
		"crouch_front", "crouch_back":
			sway_amplitude_target = Vector2(0.0, 0.08)
			sway_frequency = Vector2(0.0, 0.938)
			sway_bounce = true
		"flying":
			sway_amplitude_target = Vector2(0.0, 0.0)
			sway_frequency = Vector2(0.0, 0.0)
			sway_bounce = false
		"run_front", "run_back", "run_left", "run_right":
			sway_amplitude_target = Vector2(0.0, 0.12)
			sway_frequency = Vector2(0.0, 1.946)
			sway_bounce = true
		"sliding":
			sway_amplitude_target = Vector2(0.0, 0.0)
			sway_frequency = Vector2(0.0, 0.0)
			sway_bounce = false
		_:
			pass
