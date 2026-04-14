class_name StateHit extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.disable_hitbox()
	player.velocity.x = player.knockback_dir * player.hit_knockback_speed
	player.velocity.y = -100.0
	player.state_timer = player.hit_stun_duration
	player.iframe_timer = player.iframe_duration
	player.play_animation("hit")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	if not player.is_on_floor():
		player.velocity.x = player.knockback_dir * player.hit_knockback_speed
	else:
		player.velocity.x = 0.0
	if player.state_timer <= 0.0:
		if player.is_on_floor():
			if player._get_input_dir() != 0:
				return player.state_run
			return player.state_idle
		return player.state_fall
	return self
