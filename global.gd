extends Node

const AUTO_CONVERT_SCENES_TO_MAIN_TREE = true
var attempted_filepath: StringName = ""

signal set_main_level(path: String, preload_started: bool)


var settings = ConfigFile.new() #gets initialized by _load_settings()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#Load settings
	if !_load_settings() == OK: print("Settings failed to load.")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	############################################### could cause issues. beware?
	#CONVERT NON-PARENTED SCENE TO global.tscn/master/main/PARENTED SCENE
	#This allows the scene switcher, debug tools, etc etc to work.
	if AUTO_CONVERT_SCENES_TO_MAIN_TREE and attempted_filepath != "":
		var attempted_level = ResourceLoader.load(attempted_filepath).instantiate()
		var mainlevelcontainer = get_tree().get_first_node_in_group("main")
		for n in mainlevelcontainer.get_children():
			mainlevelcontainer.remove_child(n)
			n.queue_free()
		mainlevelcontainer.add_child(attempted_level)
		attempted_filepath = ""

	elif AUTO_CONVERT_SCENES_TO_MAIN_TREE and (not set_main_level.has_connections()) and (get_tree().current_scene != null):
		
		attempted_filepath = get_tree().current_scene.scene_file_path
		
		print("Playing '" + attempted_filepath + "' as a child of 'global.tscn' to allow admin scene switcher to work.")
		print("To disable this behavior, change AUTO_CONVERT_SCENES_TO_MAIN_TREE to false in global.gd")
		print("This is why you see the wrong scene for a quick second when you launch!!!")
		
		get_tree().change_scene_to_file("res://global.tscn")


func _unhandled_input(event: InputEvent) -> void:
	pass

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

#thanks reddit
func getFilePathsByExtension(directoryPath: String, extension: String, recursive: bool = true) -> Array:
	var dir := DirAccess.open(directoryPath)
	if dir == null:
		printerr("Warning: could not open directory: ", directoryPath)
		return []
	
	if dir.list_dir_begin() != OK:
		printerr("Warning: could not list contents of: ", directoryPath)
		return []

	var filePaths := []
	var fileName := dir.get_next()

	while fileName != "":
		if dir.current_is_dir():
			if recursive:
				var dirPath = dir.get_current_dir() + "/" + fileName
				filePaths += getFilePathsByExtension(dirPath, extension, recursive)
		else:
			if fileName.get_extension() == extension:
				var filePath = dir.get_current_dir() + "/" + fileName
				filePaths.append(filePath)
	
		fileName = dir.get_next()
	
	return filePaths
