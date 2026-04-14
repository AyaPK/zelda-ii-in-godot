class_name StateCrouch extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.play_animation("crouch")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	if not Input.is_action_pressed("crouch"):
		return player.state_idle
	if Input.is_action_just_pressed("attack"):
		return player.state_crouch_attack
	return self
