extends Node

var zoom_float: float = 0.0 #in TPS, controls distance to 3rd person cam. in freecam, controls height. in RTS, controls zoom
var zoom_accel: float = 0.1 

var transition: float = 0.0 #little bit of pull between zoom levels
enum {ZOOM_FPS, ZOOM_TPS, ZOOM_FREE, ZOOM_RTS}
var zoom_level = ZOOM_FPS #use this for functionality
var zoom_level_old = ZOOM_FPS

var angle_look: Vector2
var angle_walk: Vector2

signal zoom_level_changed(new_level)

signal cam_changed(new_cam: String)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	DebugUtils.f3_main("zoom", zoom_float)
	DebugUtils.f3_main("zoom_accel", zoom_accel)

	if zoom_accel > 0.1: zoom_accel = zoom_accel - delta * 1.2
	if zoom_accel < 0.1: zoom_accel = 0.1
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_float = zoom_float + zoom_accel
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_float = zoom_float - zoom_accel
		
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP) and event.pressed:
			zoom_accel += 0.1
			if zoom_accel > 2.5: zoom_accel = 2.5
		
		#if zoom_float > 
