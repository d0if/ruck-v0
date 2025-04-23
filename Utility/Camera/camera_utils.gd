extends Node

enum {ZOOM_FPS, ZOOM_TPS, ZOOM_FREE, ZOOM_RTS}
var zoom_level = ZOOM_FPS #use this for functionality
var zoom_level_old = ZOOM_FPS

var zoom_float: float = 0.0 #in TPS, controls distance to 3rd person cam. in freecam, controls height. in RTS, controls zoom
var zoom_accel: float = 0.1 #low scroll sensitivity when just pressed, gets higher for long scrolls

const ZOOM_FLOAT_MIN = [0.0, #ZOOM_FPS
		0.0, #ZOOM_TPS
		0.0, #ZOOM_FREE
		0.0] #ZOOM_RTS

const ZOOM_FLOAT_MAX = [0.0, #ZOOM_FPS
		8.0, #ZOOM_TPS
		15.0,#ZOOM_FREE
		3.0] #ZOOM_RTS

var transition: float = 0.0 #little bit of pull between zoom levels

var angle_look: Vector2
var angle_walk: Vector2

signal zoom_level_changed(new_level)

signal cam_changed(new_cam: String)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	DebugUtils.f3_main("zoom", zoom_float)
	DebugUtils.f3_main("zoom_accel", zoom_accel)
	
	#reset transition to 0.0, zoom_accel to 0.1 at constant rate
	transition = MathUtils.approach_line(transition, 0.0, delta * 0.2)
	zoom_accel = MathUtils.approach_line(zoom_accel, 0.1, delta * 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_float = zoom_float + zoom_accel
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_float = zoom_float - zoom_accel
		
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP) and event.pressed:
			zoom_accel += 0.2
			zoom_accel = MathUtils.cap_above(zoom_accel, 2.5)
	#zoom_float gets limited elsewhere, so don't worry about it here
