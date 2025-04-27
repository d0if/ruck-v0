extends Node

enum {ZOOM_FPS, ZOOM_TPS, ZOOM_FREE, ZOOM_RTS}
var zoom_level = ZOOM_FPS #use this for functionality
var zoom_level_old = ZOOM_FPS
signal zoom_level_changed(new_level, old_level)

var zoom_input: float = 0.0 #like zoom_float, but doesn't get capped. excess is used for transitions
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
const TRANSITION_TICK: float = 0.5 #
const TRANSITION_MINIMUM_SCROLLS: int = 8
var transition_cooldown: float = 0.0 #needs to be 0.0 for transition to happen. only decrements when at ZFMIN or ZFMAX
var TRANSITION_MINIMUM_COOLDOWN: float = 0.6

var global_cam_position: Vector3
var angle_look: Vector2
var angle_walk: Vector2

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	DebugUtils.f3_main("global cam position", global_cam_position)
	
	#zoom_input should attempt to stay within bounds. excess gets used as transition
	zoom_input = MathUtils.cap_above_line(zoom_input, ZOOM_FLOAT_MAX[zoom_level], 0.01)
	zoom_input = MathUtils.cap_below_line(zoom_input, ZOOM_FLOAT_MIN[zoom_level], 0.01)
	
	#update transition. also happens in '_scroll_input'() but it's okay to double count with this method
	transition = 0.0
	if zoom_input < ZOOM_FLOAT_MIN[zoom_level]: transition = zoom_input - ZOOM_FLOAT_MIN[zoom_level]
	if zoom_input > ZOOM_FLOAT_MAX[zoom_level]: transition = zoom_input - ZOOM_FLOAT_MAX[zoom_level]
	
	#update zoom_float (used by cameras) based on zoom_input
	zoom_float = zoom_input
	zoom_float = MathUtils.cap_below(zoom_float, ZOOM_FLOAT_MIN[zoom_level])
	zoom_float = MathUtils.cap_above(zoom_float, ZOOM_FLOAT_MAX[zoom_level])
	
	#update transition timer based on zoom_float
	if zoom_float == ZOOM_FLOAT_MAX[zoom_level] or zoom_float == ZOOM_FLOAT_MIN[zoom_level]:
		transition_cooldown = MathUtils.approach_line(transition_cooldown, 0.0, delta)
	else:
		transition_cooldown = TRANSITION_MINIMUM_COOLDOWN
	
	#scroll sensitivity decreases the longer you stop scrolling. it increases the more you scroll
	zoom_accel = MathUtils.approach_line(zoom_accel, 0.1, delta * 2.0)
	
	#need to switch camera modes if transition value passes the threshold
	if abs(transition) > TRANSITION_MINIMUM_SCROLLS * TRANSITION_TICK:
		if transition < 0: #negative transition, use closer-up cam. note that ZFPS == 0, ZTPS == 1, etc
			if zoom_level != ZOOM_FPS:
				zoom_level -= 1
				zoom_input = ZOOM_FLOAT_MAX[zoom_level]
		else:
			if zoom_level != ZOOM_RTS:
				zoom_level += 1
				zoom_input = ZOOM_FLOAT_MIN[zoom_level]
		
		if zoom_level != zoom_level_old:
			zoom_accel = 0.1
			transition = 0.0
			transition_cooldown = TRANSITION_MINIMUM_COOLDOWN
			zoom_level_changed.emit(zoom_level, zoom_level_old)
			zoom_level_old = zoom_level
	
	DebugUtils.f3_main("transition cooldown", transition_cooldown)
	DebugUtils.f3_main("zoom_input", zoom_input)
	DebugUtils.f3_main("zoom_float", zoom_float)
	DebugUtils.f3_main("zoom_accel", zoom_accel)
	DebugUtils.f3_main("transition", transition)
	DebugUtils.f3_main("zoom_level", zoom_level)


#ENTIRE purpose of this function right now is to handle zoom transitions between level
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP):
			if event.pressed:
				
				if transition_cooldown == 0.0:
					#transitioning is allowed
					if transition == 0.0:
						#not yet in transition phase
						if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
							zoom_input += zoom_accel 
							if zoom_input >= ZOOM_FLOAT_MAX[zoom_level]:
								zoom_input = ZOOM_FLOAT_MAX[zoom_level] + TRANSITION_TICK
						elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
							zoom_input -= zoom_accel 
							if zoom_input <= ZOOM_FLOAT_MIN[zoom_level]:
								zoom_input = ZOOM_FLOAT_MIN[zoom_level] - TRANSITION_TICK
					else:
						#in transition phase
						zoom_accel = 0.0
						if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
							zoom_input += TRANSITION_TICK
						elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
							zoom_input -= TRANSITION_TICK
				else:
					#transitioning is not allowed
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						zoom_input += zoom_accel 
						if zoom_input >= ZOOM_FLOAT_MAX[zoom_level]:
							zoom_input = ZOOM_FLOAT_MAX[zoom_level]
					elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
						zoom_input -= zoom_accel 
						if zoom_input <= ZOOM_FLOAT_MIN[zoom_level]:
							zoom_input = ZOOM_FLOAT_MIN[zoom_level]

				#update transition. also happens in _process() but it's okay to double count with this method
				transition = 0.0
				if zoom_input < ZOOM_FLOAT_MIN[zoom_level]: transition = zoom_input - ZOOM_FLOAT_MIN[zoom_level]
				if zoom_input > ZOOM_FLOAT_MAX[zoom_level]: transition = zoom_input - ZOOM_FLOAT_MAX[zoom_level]
				
				#update zoom_float (always equal to zoom_input but capped within ZF_MIN and ZF_MAX)
				zoom_float = zoom_input - transition
				
				if transition == 0.0: zoom_accel += 0.2
				zoom_accel = MathUtils.cap_above(zoom_accel, 2.5)

func camera_spring(delta: float, angle_ease_high: float, angle_ease_low: float, angle_firm_high: float, angle_firm_low: float) -> void:
	angle_look.y = MathUtils.cap_above_ease(angle_look.y, angle_ease_high, 1.0 - 1.0/(1+10*delta))
	angle_look.y = MathUtils.cap_below_ease(angle_look.y, angle_ease_low , 1.0 - 1.0/(1+10*delta))
	angle_look.y = MathUtils.cap_above(angle_look.y, angle_firm_high)
	angle_look.y = MathUtils.cap_below(angle_look.y, angle_firm_low )
