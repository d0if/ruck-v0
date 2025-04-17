extends Node

func is_pressing_any_movement_key(include_forward = true, include_backward = true, include_left = true, 
		include_right = true, include_jump = true, include_crouch = true, include_sprint = true, 
		include_emotes = false):
	if include_forward and Input.is_action_pressed("game_forward"):
		return true
	if include_backward and Input.is_action_pressed("game_backward"):
		return true
	if include_left and Input.is_action_pressed("game_left"):
		return true
	if include_right and Input.is_action_pressed("game_right"):
		return true
	if include_jump and Input.is_action_pressed("game_jump"):
		return true
	if include_crouch and Input.is_action_pressed("game_crouch"):
		return true
	if include_sprint and Input.is_action_pressed("game_sprint"):
		return true
	if include_emotes: #may need updated if we name emotes more distincly in the future
		for idx in range(1,90):
			var emotename = "game_emote" + str(idx)
			if not InputMap.has_action(emotename):
				break
			else:
				if Input.is_action_pressed(emotename):
					return true
	return false

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
