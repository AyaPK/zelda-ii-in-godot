class_name StateAttack extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.velocity.x = 0.0
	player.play_animation("attack")
	player.shield.active = false

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	if not player.animation_player.is_playing():
		if player._get_input_dir() != 0:
			return player.state_run
		return player.state_recoil
	player.check_sword_hits()
	return self

func exit(player: LinkSidescroll) -> void:
	player.shield.active = false
