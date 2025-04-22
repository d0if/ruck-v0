extends Node

var is_active_cam: bool = true

#children
@onready var yaw = $OriginYaw
@onready var pitch = $OriginYaw/OriginPitch
@onready var dist = $OriginYaw/OriginPitch/Distance
@onready var extra = $OriginYaw/OriginPitch/Distance/Extra
@onready var camera = $OriginYaw/OriginPitch/Distance/Extra/Camera

#zoom controls
var thirdperson: bool = false
var zoom_float: float = 0.0
var zoom_accel: float = 0.1

#configuration


####TODO
#Some controls to decide when camera is movable (e.g. not while in pause menu)
#View bobbing. abs(sin) for bounce?
#FOV effects
#toggle visibility mask for first/third person (can't see player in first person)
