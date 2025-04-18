extends Node

var zoom_float: float = 0.0 #interpolate camera between zoom levels
enum {ZOOM_FP, ZOOM_SP, ZOOM_TP}
var zoom_level = ZOOM_FP #use this for functionality
signal zoom_level_changed

var angle_look: Vector2
var angle_walk: Vector2


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
			zoom_float = zoom_float + 0.05
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_float = zoom_float - 0.05

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
