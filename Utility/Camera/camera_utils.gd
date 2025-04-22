extends Node

var zoom_float: float = 0.0 #in TPS, controls distance to 3rd person cam. in freecam, controls height. in RTS, controls zoom
var zoom_accel: float = 0.1 

var transition: float = 0.0 #little bit of pull between zoom levels
enum {ZOOM_FPS, ZOOM_FREE, ZOOM_RTS}
var zoom_level = ZOOM_FPS #use this for functionality
var thirdperson: bool = true #when in FPS mode can toggle between

signal zoom_level_changed(new_level)

var third_person: bool = true
var third_person_old: bool = true
@onready var cam_firstperson = $FirstPersonCamera
@onready var cam_thirdperson = $ThirdPersonCamera
signal cam_changed(new_cam: String)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	DebugUtils.f3_main("zoom", zoom_float)
	DebugUtils.f3_main("zoom_accel", zoom_accel)
	if zoom_level == ZOOM_FPS:
		if Input.is_action_just_pressed("ui_cameratoggle"):
			thirdperson = not thirdperson
			if zoom_level == ZOOM_FPS: cam_changed.emit(thirdperson)
	if zoom_accel > 0.1: zoom_accel = zoom_accel - delta * 2.0 #decay in 2 seconds
	if zoom_accel < 0.1: zoom_accel = 0.1
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_float = zoom_float + zoom_accel
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_float = zoom_float - zoom_accel
		
		zoom_accel += 0.1
		if zoom_accel > 1.5: zoom_accel = 1.5
		
		#if zoom_float > 

func _init_zoom_fps():
	thirdperson = false
	zoom_float = 0.75 #start off 3rdperson at 1.75 units away. 0 zoom == min dist == 1 unit
	cam_changed.emit(thirdperson)
