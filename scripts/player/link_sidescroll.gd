class_name LinkSidescroll extends CharacterBody2D

@export var move_speed: float = 90.0
@export var jump_speed: float = 230.0
@export var gravity: float = 800.0
@export var max_fall_speed: float = 600.0
@export var friction: float = 300.0
@export var landing_duration: float = 0.15
@export var recoil_duration: float = 0.5
@export var hit_stun_duration: float = 0.8
@export var hit_knockback_speed: float = 100.0
@export var iframe_duration: float = 1.8
@export var flash_interval: float = 0.08

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D

@onready var state_idle: PlayerState         = $States/Idle
@onready var state_run: PlayerState          = $States/Run
@onready var state_jump: PlayerState         = $States/Jump
@onready var state_fall: PlayerState         = $States/Fall
@onready var state_land: PlayerState         = $States/Land
@onready var state_attack: PlayerState       = $States/Attack
@onready var state_recoil: PlayerState       = $States/Recoil
@onready var state_air_attack: PlayerState   = $States/AirAttack
@onready var state_air_recoil: PlayerState   = $States/AirRecoil
@onready var state_crouch: PlayerState       = $States/Crouch
@onready var state_crouch_attack: PlayerState = $States/CrouchAttack
@onready var state_hit: PlayerState          = $States/Hit

var facing_right: bool = true
var was_on_floor: bool = true
var state_timer: float = 0.0
var iframe_timer: float = 0.0
var flash_timer: float = 0.0
var knockback_dir: float = -1.0

var _current_state: PlayerState = null
var _previous_state: PlayerState = null

var current_state: PlayerState:
	get: return _current_state

var previous_state: PlayerState:
	get: return _previous_state

func _ready() -> void:
	transition_to(state_idle)

func transition_to(next: PlayerState) -> void:
	if next == _current_state:
		return
	if _current_state:
		_current_state.exit(self)
	_previous_state = _current_state
	_current_state = next
	_current_state.enter(self)

func _physics_process(delta: float) -> void:
	state_timer -= delta
	apply_gravity(delta)
	var next := _current_state.tick(self, delta)
	move_and_slide()
	_check_landing()
	was_on_floor = is_on_floor()
	if next != _current_state:
		transition_to(next)
	$Sprite.scale.x = 1 if facing_right else -1
	$ShortswordHitboxStanding.scale.x = 1 if facing_right else -1
	$ShortswordHitboxCrouching.scale.x = 1 if facing_right else -1
	_tick_iframes(delta)

func hit(hit_source_x: float, damage: int = 1) -> void:
	if iframe_timer > 0.0:
		return
	if _current_state == state_crouch or _current_state == state_crouch_attack:
		return
	PlayerManager.current_hp -= damage
	if PlayerManager.current_hp <= 0:
		PlayerManager.current_hp = 0
		PlayerManager.on_player_death()
		return
	knockback_dir = -1.0 if hit_source_x > global_position.x else 1.0
	transition_to(state_hit)

func _tick_iframes(delta: float) -> void:
	if iframe_timer > 0.0:
		iframe_timer -= delta
		flash_timer -= delta
		if flash_timer <= 0.0:
			flash_timer = flash_interval
			$Sprite.visible = !$Sprite.visible
	else:
		$Sprite.visible = true

func _check_landing() -> void:
	if not was_on_floor and is_on_floor() and _current_state != state_land and _current_state != state_hit:
		transition_to(state_land)

func _apply_air_movement(delta: float) -> void:
	var input_dir := _get_input_dir()
	if input_dir != 0:
		facing_right = input_dir > 0
		velocity.x = input_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

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
	pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	hit(area.global_position.x)

func check_sword_hits() -> void:
	if $ShortswordHitboxStanding.monitoring:
		for area in $ShortswordHitboxStanding.get_overlapping_areas():
			var enemy := area.get_parent() as EncounterEnemy
			if enemy:
				enemy.take_hit()
	if $ShortswordHitboxCrouching.monitoring:
		for area in $ShortswordHitboxCrouching.get_overlapping_areas():
			var enemy := area.get_parent() as EncounterEnemy
			if enemy:
				enemy.take_hit()

func enable_hitbox() -> void:
	if animation_player.current_animation == "attack" or animation_player.current_animation == "air_attack":
		$ShortswordHitboxStanding.monitoring = true
		$ShortswordHitboxStanding.set_deferred("monitorable", true)
		$ShortswordHitboxStanding.show()
	elif animation_player.current_animation == "crouch_attack":
		$ShortswordHitboxCrouching.monitoring = true
		$ShortswordHitboxCrouching.set_deferred("monitorable", true)
		$ShortswordHitboxCrouching.show()

func disable_hitbox() -> void:
	$ShortswordHitboxStanding.monitoring = false
	$ShortswordHitboxStanding.set_deferred("monitorable", false)
	$ShortswordHitboxStanding.hide()
	$ShortswordHitboxCrouching.monitoring = false
	$ShortswordHitboxCrouching.set_deferred("monitorable", false)
	$ShortswordHitboxCrouching.hide()
