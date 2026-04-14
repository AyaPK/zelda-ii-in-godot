class_name StateAirAttack extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.play_animation("air_attack")
	player.enable_hitbox()

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	player._apply_air_movement(delta)
	if player.is_on_floor():
		return player.state_land
	if not player.animation_player.is_playing():
		if player._get_input_dir() != 0:
			if player.velocity.y < 0:
				return player.state_jump
			return player.state_fall
		return player.state_air_recoil
	return self
