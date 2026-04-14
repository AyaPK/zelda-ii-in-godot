class_name StateRecoil extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.state_timer = player.recoil_duration
	player.velocity.x = 0.0
	player.disable_hitbox()
	player.play_animation("recoil")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	if Input.is_action_just_pressed("attack"):
		return player.state_attack
	if Input.is_action_pressed("crouch"):
		return player.state_crouch
	if player.state_timer <= 0 or player._get_input_dir() != 0:
		if player._get_input_dir() != 0:
			return player.state_run
		return player.state_idle
	return self
