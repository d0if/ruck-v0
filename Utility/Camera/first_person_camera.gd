extends Node3D

const ANGLE_SPRING: float = (PI/2.0)*(5.0/6.0)
const ANGLE_MAX: float = ANGLE_SPRING * 2.0

const WALK_HEIGHT = 0.0
const CROUCH_HEIGHT = -0.5

var target_fov: float = 75.0

var height_tween: Tween

@onready var gimbal = $Gimbal
@onready var camera = $Gimbal/Camera

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

		if abs(Global.angle_look.y) > ANGLE_SPRING: #1/1+10d is for keeping spring consistent @ diff framerates
			Global.angle_look.y = camera_spring(Global.angle_look.y, 1/(1+10*delta))
		
		gimbal.rotation.y = -Global.angle_look.x #temporarily removed for 3rd person
		camera.rotation.x = -Global.angle_look.y
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Global.angle_look.x = Global.angle_look.x + event.screen_relative.x * Global.settings.get_value("mouse", "sensitivity").x
		Global.angle_look.y = Global.angle_look.y + event.screen_relative.y * Global.settings.get_value("mouse", "sensitivity").y
	elif event is InputEventJoypadMotion:
		pass
	
	Global.angle_look.x = MathUtils.cap_radians(Global.angle_look.x)

func camera_spring(pitch: float, springiness: float) -> float:
	if pitch > ANGLE_SPRING:
		pitch = ANGLE_SPRING + (pitch - ANGLE_SPRING) * springiness
		if pitch > ANGLE_MAX:
			pitch = ANGLE_MAX
	if pitch < -ANGLE_SPRING:
		pitch = -ANGLE_SPRING + (pitch + ANGLE_SPRING) * springiness
		if pitch < -ANGLE_MAX:
			pitch = -ANGLE_MAX
	
	return pitch


func _on_test_bean_height_changed(is_short: bool) -> void:
	if height_tween:
		height_tween.kill()
	
	height_tween = create_tween()
	var new_location = CROUCH_HEIGHT if is_short else WALK_HEIGHT
	height_tween.tween_property(gimbal, "position:y", new_location, 0.1)


func _on_test_rucker_mvt_speed_changed(new_speed: float) -> void:
	target_fov = 75.0 + 2*sqrt(new_speed) - 10
