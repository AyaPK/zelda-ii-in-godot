class_name StateAirRecoil extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.state_timer = player.recoil_duration
	player.disable_hitbox()
	player.play_animation("recoil")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	player._apply_air_movement(delta)
	if player.is_on_floor():
		return player.state_land
	if Input.is_action_just_pressed("attack"):
		return player.state_air_attack
	if player.state_timer <= 0 or player._get_input_dir() != 0:
		if player.velocity.y < 0:
			return player.state_jump
		return player.state_fall
	return self
