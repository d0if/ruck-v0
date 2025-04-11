extends Node

var zoom_float: float = 0.0 #interpolate camera between zoom levels
enum {ZOOM_FP, ZOOM_SP, ZOOM_TP}
var zoom_level = ZOOM_FP #use this for functionality

var angle_look: Vector2
var angle_walk: Vector2

var debug_text_physics: String = ""
var debug_text_process: String = ""
var debug_text_logging: Array = []
var debug_duration_log: Array = []

var settings = ConfigFile.new() #gets initialized by _load_settings()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#Load settings
	if !_load_settings() == OK: print("Settings failed to load.")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_float = zoom_float + 0.01
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_float = zoom_float - 0.01

func _load_settings() -> Error:
	#loads settings&makes sure that every field in settings_default is available
	var _settings_default = ConfigFile.new()
	var _count_changes = 0
	if _settings_default.load("res://Player/settings_default.cfg") == OK:
		if settings.load("user://settings.cfg") == OK:
			
			#settings & default both loaded. make sure everything is available
			var _settings_sections_default = _settings_default.get_sections()			
			#iterate over _settings_default & find what may be needed
			for _ssd in _settings_sections_default:
				var _settings_entries_default = _settings_default.get_section_keys(_ssd)
				for _sed in _settings_entries_default:
					if !settings.has_section_key(_ssd, _sed):
						_count_changes = _count_changes + 1
						settings.set_value(_ssd, _sed, _settings_default.get_value(_ssd, _sed))
			
			if _count_changes > 0:
				#update settings with new changes
				settings.save("user://settings.cfg")
				print("Added " + str(_count_changes) + " new setting(s) to match default.")
		else:
			
			#settings not found, default was found, turn default into settings
			_settings_default.save("user://settings.cfg")
			
			#make sure the changes are available
			if !settings.load("user://settings.cfg") == OK:
				print("Error importing default settings.")
				return FAILED
			else:
				print("Imported first-time settings from default.")
	else:
		#default settings not available you're cooked
		print("Error reading default settings.")
		return FAILED
		
	return OK

func debug_phys(label: String = "", value = ""):
	debug_text_physics = debug_text_physics + "\n"
	if label != "":
		debug_text_physics = debug_text_physics + label + ": "
	debug_text_physics = debug_text_physics + str(value)

func debug(label: String = "", value = ""):
	debug_text_process = debug_text_process + "\n"
	if label != "":
		debug_text_process = debug_text_process + label + ": "
	debug_text_process = debug_text_process + str(value)

func debug_log(value = "", duration: float = 2.0, label: String = ""):
	var temp_debug_text = label + ": " if label != "" else ""
	temp_debug_text = temp_debug_text + str(value)
	debug_text_logging.push_front(temp_debug_text)
	debug_duration_log.push_front(duration)

func get_horizontal_movement_from_keyboard() -> Vector2:
	var trial_angle = Vector2(0.0, 0.0) #x is right/left, y is forward/back
	if Input.is_action_pressed("game_forward"):
		trial_angle.y = trial_angle.y + 1.0
	if Input.is_action_pressed("game_backward"):
		trial_angle.y = trial_angle.y - 1.0
	if Input.is_action_pressed("game_left"):
		trial_angle.x = trial_angle.x - 1.0
	if Input.is_action_pressed("game_right"):
		trial_angle.x = trial_angle.x + 1.0
	
	if abs(trial_angle.x) + abs(trial_angle.y) > 1.0:
		#moving diagonally gives you a slight buff (0.8 rather than 0.717)
		trial_angle = trial_angle * 0.8
	
	return trial_angle
