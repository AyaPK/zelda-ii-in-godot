class_name StateLand extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.state_timer = player.landing_duration
	player.disable_hitbox()
	player.play_animation("land")
	player.set_crouch_shield(true)
	player.attack_consumed = false

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	if Input.is_action_just_pressed("jump"):
		return player.state_jump
	if Input.is_action_pressed("crouch"):
		return player.state_crouch
	if player.state_timer <= 0:
		if player._get_input_dir() != 0:
			return player.state_run
		return player.state_idle
	return self

func exit(player: LinkSidescroll) -> void:
	player.set_crouch_shield(false)
