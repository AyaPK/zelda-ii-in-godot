class_name StateFall extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.play_animation("fall")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	player._apply_air_movement(delta)
	if Input.is_action_just_pressed("attack"):
		return player.state_air_attack
	if player.is_on_floor():
		return player.state_land
	return self
