extends Node

var third_person: bool = true
var third_person_old: bool = true
@onready var cam_firstperson = $FirstPersonCamera
@onready var cam_thirdperson = $ThirdPersonCamera
signal cam_changed(new_cam: String)

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	pass
