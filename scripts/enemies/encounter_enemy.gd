class_name EncounterEnemy extends CharacterBody2D

@export var xp_value: int = 0
@export var max_hp: int = 1
@export var attack: int = 8
@export var blockable: bool = true
@export var hit_stun_duration: float = 1
@export var iframe_duration: float = 1
@export var flash_interval: float = 0.07
@export var flash_color: Color = Color(1, 0.2, 0.2)

var spawner: OnScreenSpawner

const STRENGTHS: Array[int] = [8, 16, 24, 48, 72, 112]
const DAMAGE_TABLE: Array = [
	[8,  6,  6,  6,  4,  4,  2,  2],
	[16, 14, 10,  8,  6,  6,  4,  4],
	[24, 20, 18, 16, 12, 10,  8,  6],
	[48, 36, 28, 24, 20, 16, 14, 12],
	[72, 60, 48, 36, 28, 24, 20, 16],
	[112, 80, 64, 56, 48, 40, 32, 24],
]

var hp: int = 0
var hit_stun_timer: float = 0.0
var iframe_timer: float = 0.0
var flash_timer: float = 0.0
var is_stunned: bool = false

func _ready() -> void:
	hp = max_hp

func _process(delta: float) -> void:
	if iframe_timer > 0.0:
		iframe_timer -= delta
		flash_timer -= delta
		if flash_timer <= 0.0:
			flash_timer = flash_interval
			$Sprite2D.modulate = flash_color if $Sprite2D.modulate == Color.WHITE else Color.WHITE
	else:
		$Sprite2D.modulate = Color.WHITE

	if is_stunned:
		hit_stun_timer -= delta
		if hit_stun_timer <= 0.0:
			is_stunned = false

func take_hit(damage: int = 1) -> bool:
	if iframe_timer > 0.0:
		return false
	hp -= damage
	if hp <= 0:
		die()
		return true
	is_stunned = true
	hit_stun_timer = hit_stun_duration
	iframe_timer = iframe_duration
	flash_timer = flash_interval
	return true

func hit_player(player: LinkSidescroll) -> void:
	var strength_idx: int = STRENGTHS.find(attack)
	if strength_idx == -1:
		strength_idx = 0
		for i in range(STRENGTHS.size() - 1, -1, -1):
			if attack >= STRENGTHS[i]:
				strength_idx = i
				break
	var life_idx: int = clampi(PlayerManager.levels["life"] - 1, 0, 7)
	var damage: int = DAMAGE_TABLE[strength_idx][life_idx]
	player.hit(global_position.x, damage)
	if Scenemanager.hud:
		Scenemanager.hud.refresh_hud()

func die() -> void:
	if spawner:
		spawner.enemy_alive = false
	queue_free()

func blocked() -> void:
	pass
