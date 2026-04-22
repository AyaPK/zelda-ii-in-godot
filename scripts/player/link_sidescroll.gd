class_name LinkSidescroll extends CharacterBody2D

@export var move_speed: float = 90.0
@export var jump_speed: float = 230.0
@export var gravity: float = 820.0
@export var max_fall_speed: float = 600.0
@export var friction: float = 300.0
@export var air_acceleration: float = 400.0
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
@onready var shield: Shield = $Shield

var facing_right: bool = true
var was_on_floor: bool = true
var attack_consumed: bool = false
var state_timer: float = 0.0
var iframe_timer: float = 0.0
var flash_timer: float = 0.0
var knockback_dir: float = -1.0
var on_elevator: bool = false
var interactable: Interactable = null

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

func _process(_delta: float) -> void:
	if interactable and Input.is_action_just_pressed("attack"):
		print("a")
		interactable.activate()

func _physics_process(delta: float) -> void:
	state_timer -= delta
	apply_gravity(delta)
	var next := _current_state.tick(self, delta)
	move_and_slide()
	var state_before_landing := _current_state
	_check_landing()
	was_on_floor = is_on_floor()
	if _current_state == state_before_landing and next != _current_state:
		transition_to(next)
	var face_scale =  1 if facing_right else -1
	$Sprite.scale.x = face_scale
	$Shield.scale.x = face_scale
	$Shield.facing_right = facing_right
	$ShortswordHitboxStanding.scale.x = face_scale
	$ShortswordHitboxCrouching.scale.x = face_scale
	_tick_iframes(delta)

func hit(hit_source_x: float, damage: int = 2) -> void:
	if iframe_timer > 0.0:
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
		var target_x := input_dir * move_speed
		velocity.x = move_toward(velocity.x, target_x, air_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, air_acceleration * delta)

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
	var enemy := area.get_parent() as EncounterEnemy
	if enemy:
		if enemy.blockable and _is_blocked(enemy.global_position.x, self):
			enemy.blocked()
			shield_blocked(self)
			return
		enemy.hit_player(self)
		return
	var projectile := area as EnemyProjectile
	if projectile:
		if projectile.blockable and _is_blocked(projectile.global_position.x, self):
			projectile.blocked()
			shield_blocked(self)
			return
		projectile.hit_player(self)
		return

const SWORD_DAMAGE: Array[int] = [2, 3, 4, 6, 9, 12, 18, 24]

func _get_sword_damage() -> int:
	var idx: int = clampi(PlayerManager.levels["attack"] - 1, 0, 7)
	return SWORD_DAMAGE[idx]

func _is_blocked(attacker_global_x: float, target: Node) -> bool:
	var shieldd := target.get_node_or_null("Shield") as Shield
	if shieldd == null or not shieldd.active:
		return false
	var attack_from_right: bool = attacker_global_x > target.global_position.x
	if shieldd.facing_right != attack_from_right:
		return false
	return not shieldd.get_overlapping_areas().is_empty()

func shield_blocked(_target: Node) -> void:
	pass

func check_sword_hits() -> void:
	var damage := _get_sword_damage()
	if $ShortswordHitboxStanding.monitoring:
		for area in $ShortswordHitboxStanding.get_overlapping_areas():
			var enemy := area.get_parent() as EncounterEnemy
			if enemy:
				if _is_blocked(global_position.x, enemy):
					shield_blocked(enemy)
					continue
				if enemy.take_hit(damage):
					AudioManager.play_sfx("sword_hit")
	elif $ShortswordHitboxCrouching.monitoring:
		for area in $ShortswordHitboxCrouching.get_overlapping_areas():
			var enemy := area.get_parent() as EncounterEnemy
			if enemy:
				if _is_blocked(global_position.x, enemy):
					shield_blocked(enemy)
					continue
				if enemy.take_hit(damage):
					AudioManager.play_sfx("sword_hit")
				

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

func set_crouch_shield(is_crouched: bool) -> void:
	if is_crouched:
		$Shield.position.y = 13.0
	else:
		$Shield.position.y = 0.0
	pass
