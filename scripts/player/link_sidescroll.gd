class_name LinkSidescroll extends CharacterBody2D

enum State { IDLE, RUN, JUMP, FALL, LAND, ATTACK, RECOIL, AIR_ATTACK, AIR_RECOIL, CROUCH, CROUCH_ATTACK, HIT }

@export var move_speed: float = 90.0
@export var jump_speed: float = 230.0
@export var gravity: float = 800.0
@export var max_fall_speed: float = 600.0
@export var friction: float = 300.0
@export var landing_duration: float = 0.15
@export var recoil_duration: float = 0.5
@export var hit_stun_duration: float = 0.8
@export var hit_knockback_speed: float = 100.0
@export var iframe_duration: float = 1.2
@export var flash_interval: float = 0.08

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D

var facing_right: bool = true
var was_on_floor: bool = true
var state: State = State.IDLE
var state_timer: float = 0.0
var iframe_timer: float = 0.0
var flash_timer: float = 0.0
var knockback_dir: float = -1.0

func _physics_process(delta: float) -> void:
	state_timer -= delta
	apply_gravity(delta)
	var next_state := _tick_state(delta)
	move_and_slide()
	_check_landing()
	was_on_floor = is_on_floor()
	if next_state != state:
		_enter_state(next_state)
	$Sprite.scale.x = 1 if facing_right else -1
	_tick_iframes(delta)

func _tick_state(delta: float) -> State:
	match state:
		State.IDLE:
			return _tick_idle()
		State.RUN:
			return _tick_run()
		State.JUMP:
			return _tick_jump()
		State.FALL:
			return _tick_fall()
		State.LAND:
			return _tick_land()
		State.ATTACK:
			return _tick_attack()
		State.RECOIL:
			return _tick_recoil()
		State.AIR_ATTACK:
			return _tick_air_attack()
		State.AIR_RECOIL:
			return _tick_air_recoil()
		State.CROUCH:
			return _tick_crouch()
		State.CROUCH_ATTACK:
			return _tick_crouch_attack()
		State.HIT:
			return _tick_hit()
	return state

func _enter_state(new_state: State) -> void:
	state = new_state
	match state:
		State.IDLE:
			play_animation("idle")
		State.RUN:
			play_animation("run")
		State.JUMP:
			velocity.y = -jump_speed
			play_animation("jump")
		State.FALL:
			play_animation("fall")
		State.LAND:
			state_timer = landing_duration
			play_animation("land")
		State.ATTACK:
			velocity.x = 0.0
			play_animation("attack")
		State.RECOIL:
			state_timer = recoil_duration
			velocity.x = 0.0
			play_animation("recoil")
		State.AIR_ATTACK:
			play_animation("air_attack")
		State.AIR_RECOIL:
			state_timer = recoil_duration
			play_animation("recoil")
		State.CROUCH:
			play_animation("crouch")
		State.CROUCH_ATTACK:
			play_animation("crouch_attack")
		State.HIT:
			velocity.x = knockback_dir * hit_knockback_speed
			velocity.y = -160.0
			state_timer = hit_stun_duration
			iframe_timer = iframe_duration
			play_animation("hit")

func hit(hit_source_x: float) -> void:
	if iframe_timer > 0.0:
		return
	knockback_dir = -1.0 if hit_source_x > global_position.x else 1.0
	_enter_state(State.HIT)

func _tick_hit() -> State:
	if not is_on_floor():
		velocity.x = knockback_dir * hit_knockback_speed
	else:
		velocity.x = 0.0
	if state_timer <= 0.0:
		if is_on_floor():
			if _get_input_dir() != 0:
				return State.RUN
			return State.IDLE
		return State.FALL
	return State.HIT

func _tick_iframes(delta: float) -> void:
	if iframe_timer > 0.0:
		iframe_timer -= delta
		flash_timer -= delta
		if flash_timer <= 0.0:
			flash_timer = flash_interval
			$Sprite.visible = !$Sprite.visible
	else:
		$Sprite.visible = true

func _tick_idle() -> State:
	var input_dir := _get_input_dir()
	if input_dir != 0:
		facing_right = input_dir > 0
		velocity.x = input_dir * move_speed
		return State.RUN
	velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())
	if not is_on_floor():
		return State.FALL
	if Input.is_action_just_pressed("jump"):
		return State.JUMP
	if Input.is_action_pressed("crouch"):
		return State.CROUCH
	if Input.is_action_just_pressed("attack"):
		return State.ATTACK
	return State.IDLE

func _tick_run() -> State:
	var input_dir := _get_input_dir()
	if input_dir != 0:
		facing_right = input_dir > 0
		velocity.x = input_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())
	if not is_on_floor():
		return State.FALL
	if Input.is_action_just_pressed("jump"):
		return State.JUMP
	if Input.is_action_pressed("crouch"):
		return State.CROUCH
	if Input.is_action_just_pressed("attack"):
		return State.ATTACK
	if velocity.x == 0.0 and input_dir == 0:
		return State.IDLE
	return State.RUN

func _tick_jump() -> State:
	_apply_air_movement()
	if Input.is_action_just_pressed("attack"):
		return State.AIR_ATTACK
	if velocity.y >= 0:
		return State.FALL
	return State.JUMP

func _tick_fall() -> State:
	_apply_air_movement()
	if Input.is_action_just_pressed("attack"):
		return State.AIR_ATTACK
	if is_on_floor():
		return State.LAND
	return State.FALL

func _tick_land() -> State:
	#velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())
	if Input.is_action_just_pressed("jump"):
		return State.JUMP
	if state_timer <= 0:
		if _get_input_dir() != 0:
			return State.RUN
		return State.IDLE
	return State.LAND

func _tick_air_attack() -> State:
	_apply_air_movement()
	if is_on_floor():
		return State.LAND
	if not animation_player.is_playing():
		if _get_input_dir() != 0:
			if velocity.y < 0:
				return State.JUMP
			return State.FALL
		return State.AIR_RECOIL
	return State.AIR_ATTACK

func _tick_air_recoil() -> State:
	_apply_air_movement()
	if is_on_floor():
		return State.LAND
	if Input.is_action_just_pressed("attack"):
		return State.AIR_ATTACK
	if state_timer <= 0 or _get_input_dir() != 0:
		if velocity.y < 0:
			return State.JUMP
		return State.FALL
	return State.AIR_RECOIL

func _tick_crouch() -> State:
	velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())
	if not Input.is_action_pressed("crouch"):
		return State.IDLE
	if Input.is_action_just_pressed("attack"):
		return State.CROUCH_ATTACK
	return State.CROUCH

func _tick_crouch_attack() -> State:
	velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())
	if not animation_player.is_playing():
		if Input.is_action_pressed("crouch"):
			return State.CROUCH
		return State.IDLE
	return State.CROUCH_ATTACK

func _tick_attack() -> State:
	if not animation_player.is_playing():
		if _get_input_dir() != 0:
			return State.RUN
		return State.RECOIL
	return State.ATTACK

func _tick_recoil() -> State:
	if Input.is_action_just_pressed("attack"):
		return State.ATTACK
	if state_timer <= 0 or _get_input_dir() != 0:
		if _get_input_dir() != 0:
			return State.RUN
		return State.IDLE
	return State.RECOIL

func _check_landing() -> void:
	if not was_on_floor and is_on_floor() and state != State.LAND and state != State.HIT:
		_enter_state(State.LAND)

func _apply_air_movement() -> void:
	var input_dir := _get_input_dir()
	if input_dir != 0:
		facing_right = input_dir > 0
		velocity.x = input_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())

func _get_input_dir() -> float:
	var input_dir: float = 0.0
	if Input.is_action_pressed("move_left"):
		input_dir -= 1
	if Input.is_action_pressed("move_right"):
		input_dir += 1
	return input_dir

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
	elif velocity.y > 0:
		velocity.y = 0

func play_animation(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func _on_camera_boundary_left_screen_entered() -> void:
	pass # Replace with function body.

func _on_hurtbox_area_entered(area: Area2D) -> void:
	hit(area.global_position.x)
