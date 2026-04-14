class_name StateCrouchAttack extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.play_animation("crouch_attack")
	player.enable_hitbox()

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	if not player.animation_player.is_playing():
		if Input.is_action_pressed("crouch"):
			return player.state_crouch
		return player.state_idle
	return self
