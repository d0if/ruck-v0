extends Node

var show_debug = false
var show_admin = false
signal admin_panel_toggled(state: bool)
signal admin_panel_closed()

var debug_text_physics: String = ""
var debug_text_process: String = ""
var debug_text_logging: Array = []
var debug_duration_log: Array = []

var debug_text: String = ""


func _process(delta: float) -> void:
	show_debug = show_debug != Input.is_action_just_pressed("ui_showdebug") #toggle f3 mode
	if Input.is_action_just_pressed("ui_showadmin"):
		admin_panel_toggled.emit(not show_admin)

	debug_text = debug_text_process + "\n"
	var half_physics_text = debug_text_physics.left(debug_text_physics.length()/2)
	debug_text = debug_text + half_physics_text + "\n"
	var to_delete: Array = []
	for index in range(0, len(debug_text_logging)):
		debug_duration_log[index] = debug_duration_log[index] - delta
		if debug_duration_log[index] < 0:
			to_delete.append(index)
	
	for entry in to_delete:
		debug_duration_log.pop_back()
		debug_text_logging.pop_back()
	
	for entry in debug_text_logging:
		debug_text = debug_text + str(entry) + "\n"
	
	debug_text_process = ""
	debug_text_physics = ""

func f3_phys(label: String = "", value = ""):
	
	debug_text_physics = debug_text_physics + "\n"
	if label != "":
		debug_text_physics = debug_text_physics + label + ": "
	debug_text_physics = debug_text_physics + str(value)

func f3_main(label: String = "", value = ""):
	debug_text_process = debug_text_process + "\n"
	if label != "":
		debug_text_process = debug_text_process + label + ": "
	debug_text_process = debug_text_process + str(value)

func f3_log(value = "", duration: float = 2.0, label: String = ""):
	var temp_debug_text = label + ": " if label != "" else ""
	temp_debug_text = temp_debug_text + str(value)
	debug_text_logging.push_front(temp_debug_text)
	debug_duration_log.push_front(duration)
