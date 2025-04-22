extends Node

@onready var mainlevelcontainer = $Main

var defaultscene: bool = true
var loadingpath: String = ""

func _ready() -> void:
	Global.set_main_level.connect(_try_set_main_level)
	#get current main scene from editor (so we don't have to declare it in code)
	pass #nvm, using defaultscene bool for now

func _process(delta: float) -> void:
	#keep watch if we're loading a file
	if loadingpath != "":
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(loadingpath, progress)
		
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED or status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("Critical resource load failure on " + loadingpath)
			loadingpath = ""
		elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			#get progress bar status if u want
			pass
		elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			_set_main_level(loadingpath)
			loadingpath = ""

func _try_set_main_level(path: String, preload_started: bool):
	if preload_started:
		#see if preload is done, otherwise set loadingpath so that _process will keep watch
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			_set_main_level(path)
		else:
			loadingpath = path
	else:
		#start preloading and set loadingpath so that _process will keep watch
		ResourceLoader.load_threaded_request(path)
		loadingpath = path
	
func _set_main_level(path: String):
	#we know that ResourceLoader has successfully loaded the file path of new main level.
	#clear the main level node's children and replace with ^^
	for n in mainlevelcontainer.get_children():
		mainlevelcontainer.remove_child(n)
		n.queue_free()
	
	var new_level = ResourceLoader.load_threaded_get(path).instantiate()
	mainlevelcontainer.add_child(new_level)
	
	DebugUtils.admin_panel_closed.emit()
