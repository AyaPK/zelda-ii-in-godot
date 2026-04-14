class_name StateJump extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.velocity.y = -player.jump_speed
	player.play_animation("jump")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	player._apply_air_movement(delta)
	if Input.is_action_just_pressed("attack"):
		return player.state_air_attack
	if player.velocity.y >= 0:
		return player.state_fall
	return self
