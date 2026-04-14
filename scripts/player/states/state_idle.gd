class_name StateIdle extends PlayerState

func enter(player: LinkSidescroll) -> void:
	player.play_animation("idle")

func tick(player: LinkSidescroll, delta: float) -> PlayerState:
	var input_dir := player._get_input_dir()
	if input_dir != 0:
		player.facing_right = input_dir > 0
		player.velocity.x = input_dir * player.move_speed
		return player.state_run
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	if not player.is_on_floor():
		return player.state_fall
	if Input.is_action_just_pressed("jump"):
		return player.state_jump
	if Input.is_action_pressed("crouch"):
		return player.state_crouch
	if Input.is_action_just_pressed("attack"):
		return player.state_attack
	return self
