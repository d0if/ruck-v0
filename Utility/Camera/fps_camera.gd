extends Node

#var active: bool = true #instead of this, try to design UI that absorbs mouse input

#children
@onready var yaw = $Yaw
@onready var pitch = $Yaw/Pitch
@onready var dist = $Yaw/Pitch/Distance
@onready var sway = $Yaw/Pitch/Distance/Sway
@onready var freelook_yaw = $Yaw/Pitch/Distance/Sway/FreeYaw
@onready var freelook_pitch = $Yaw/Pitch/Distance/Sway/FreeYaw/FreePitch
@onready var camera = $Yaw/Pitch/Distance/Sway/FreeYaw/FreePitch/Camera3D
@onready var rayend = $Yaw/Pitch/RayEnd

####TODO
#Some controls to decide when camera is movable (e.g. not while in pause menu)
#View bobbing. abs(sin) for bounce?
#FOV effects
#toggle visibility mask for first/third person (can't see player in first person)
