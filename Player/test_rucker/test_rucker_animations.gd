extends Node3D

var height_tween: Tween
const WALK_HEIGHT = -1.05
const CROUCH_HEIGHT = -1.55

var emoting = false
var traversal_emote = false

@onready var rootedAnimator = $AnimationPlayerRooted
@onready var unrootedAnimator = $AnimationPlayerUnrooted

var animations: PackedStringArray = ["RESET", "Crouch Idle", "Crouch Walk", "Crouch to Stand", 
		"Fall", "Happy Idle", "Joyful Jump", "Jump", "Land", "Macarena", 
		"Run Backwards", "Run Forward", "Run Jump", "Slide", "RESET", #note "Standing Idle" renamed to "RESET" since it's default
		"Standing to Crouch", "Strafe Left", "Strafe Right", "Twerk", "YMCA"]
enum {ANIM_RESET, ANIM_CROUCHIDLE, ANIM_CROUCHWALK, ANIM_CROUCH_STAND, 
		ANIM_FALL, ANIM_HAPPYIDLE, ANIM_JOYFULJUMP, ANIM_JUMP, ANIM_LAND, ANIM_MACARENA, 
		ANIM_RUNBACKWARDS, ANIM_RUNFORWARD, ANIM_RUN_JUMP, ANIM_SLIDE, ANIM_STANDIDLE, 
		ANIM_STAND_CROUCH, ANIM_STRAFE_L, ANIM_STRAFE_R, ANIM_TWERK, ANIM_YMCA}
#can safely access an animation after name changes with 
#animations[ANIM_RUNFORWARD] etc etc since enums are just 0,1,...

func _ready() -> void:
	#maybe better to do this by queuing?
	#animator.animation_set_next("Jump", "Fall")
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("game_emote1"):
		emoting = true
		unrootedAnimator.play(animations[ANIM_JOYFULJUMP])
	if Input.is_action_just_pressed("game_emote2"):
		emoting = true
		unrootedAnimator.play(animations[ANIM_MACARENA])
	if Input.is_action_just_pressed("game_emote3"):
		emoting = true
		unrootedAnimator.play(animations[ANIM_TWERK])
	if Input.is_action_just_pressed("game_emote4"):
		emoting = true
		unrootedAnimator.play(animations[ANIM_YMCA])
	

func _on_test_rucker_mvt_style_changed(new_anim: StringName, old_anim: StringName) -> void:
	#possible movement (animation) states:
	#idle, walk_front/back/left/right, crouched, crouch_front (no back/left/right yet),
	#jumped, flying, landed, run_front/back (no left/right yet), sliding
	DebugUtils.f3_log(new_anim)
	
	if new_anim != "idle" and emoting:
		emoting = false
	
	match new_anim:
		"idle":
			if not emoting:
				unrootedAnimator.play(animations[ANIM_STANDIDLE])
		"walk_front":
			unrootedAnimator.play(animations[ANIM_RUNFORWARD])
		"walk_back":
			unrootedAnimator.play(animations[ANIM_RUNBACKWARDS])
		"walk_left":
			unrootedAnimator.play(animations[ANIM_STRAFE_L])
		"walk_right":
			unrootedAnimator.play(animations[ANIM_STRAFE_R])
		"crouched":
			unrootedAnimator.play(animations[ANIM_CROUCHIDLE])
		"crouch_front":
			unrootedAnimator.play(animations[ANIM_CROUCHWALK])
		"crouch_back":
			unrootedAnimator.play(animations[ANIM_CROUCHWALK]) # i thought there was a crouch back anim oops
		"flying":
			unrootedAnimator.play(animations[ANIM_FALL])
		"run_front":
			unrootedAnimator.play(animations[ANIM_RUNFORWARD], -1, 1.5)
		"run_back":
			unrootedAnimator.play(animations[ANIM_RUNBACKWARDS], -1, 1.5)
		"run_left":
			unrootedAnimator.play(animations[ANIM_STRAFE_L], -1, 1.5)
		"run_right":
			unrootedAnimator.play(animations[ANIM_STRAFE_R], -1, 1.5)
		"sliding":
			unrootedAnimator.play(animations[ANIM_SLIDE])
		_:
			pass
	

#no longer necessary due to unrooted animations
#func _on_test_rucker_height_changed(is_short: bool) -> void:
	#if height_tween:
		#height_tween.kill()
	#
	#height_tween = create_tween()
	#var new_location = CROUCH_HEIGHT if is_short else WALK_HEIGHT
	#height_tween.tween_property(self, "position:y", new_location, 0.1)
