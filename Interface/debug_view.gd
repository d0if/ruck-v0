extends Control

const LEVELS_PATH = "res://Environments"
const UI_PATH = "res://Interface"
var levels_loaded: bool = false

var remembered_mousemode

@onready var debugview = $"Debug"
@onready var adminview = $"Scene Selector"
@onready var levelmenu = $"Scene Selector/HBoxContainer/scenes"
@onready var levelbutton = $"Scene Selector/HBoxContainer/scenes/Button"
@onready var uimenu = $"Scene Selector/HBoxContainer/uis"
@onready var uibutton = $"Scene Selector/HBoxContainer/uis/Button2"

func _ready() -> void:
	DebugUtils.admin_panel_toggled.connect(_on_admin_panel_toggled)
	DebugUtils.admin_panel_closed.connect(_on_admin_panel_closed)


func _process(delta: float) -> void:
	debugview.visible = DebugUtils.show_debug
	debugview.text = DebugUtils.debug_text

func _on_admin_panel_toggled(state: bool):
	if state:
		DebugUtils.show_admin = true
		adminview.visible = true
		remembered_mousemode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		DebugUtils.show_admin = false
		adminview.visible = false
		Input.mouse_mode = remembered_mousemode
		return
	
	#we are loading the admin panel, so scan the environments folder for playable levels
	if not levels_loaded:
		_on_refresh_button_up()

func _on_admin_panel_closed():
	DebugUtils.show_admin = false #only difference from the toggle is that we will not mess with the mouse mode
	adminview.visible = false
	return


#admin level selector searcher
func _on_refresh_button_up() -> void:
	#remove old results, if any are found
	for n in levelmenu.get_children():
		if n.get_meta("path", "") != "": #only the default (hidden) buttons have blank path
			levelmenu.remove_child(n)
			n.queue_free()
	for n in uimenu.get_children():
		if n.get_meta("path", "") != "":
			levelmenu.remove_child(n)
			n.queue_free()
	
	var levels = Global.getFilePathsByExtension(LEVELS_PATH, "tscn")
	var uis = Global.getFilePathsByExtension(UI_PATH, "tscn")
	DebugUtils.f3_log("ADMIN: got levels from directory")
	for level_path in levels:
		var new_levelbutton = levelbutton.duplicate()
		new_levelbutton.visible = true
		new_levelbutton.text = level_path.split("/")[-1] #janky, but turns "res://blah/test.txt" to "test.txt"
		new_levelbutton.set_meta("path", level_path)
		levelmenu.add_child(new_levelbutton)
	for ui_path in uis:
		var new_uibutton = uibutton.duplicate()
		new_uibutton.visible = true
		new_uibutton.text = ui_path.split("/")[-1] #janky, but turns "res://blah/test.txt" to "test.txt"
		new_uibutton.set_meta("path", ui_path)
		uimenu.add_child(new_uibutton)
	levels_loaded = true
