class_name EncounterEnemy extends CharacterBody2D

@export var xp_value: int = 0
@export var max_hp: int = 1
@export var hit_stun_duration: float = 0.4
@export var iframe_duration: float = 0.6
@export var flash_interval: float = 0.07

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
			$Sprite2D.visible = !$Sprite2D.visible
	else:
		$Sprite2D.visible = true

	if is_stunned:
		hit_stun_timer -= delta
		if hit_stun_timer <= 0.0:
			is_stunned = false

func take_hit(damage: int = 1) -> void:
	queue_free()
	if iframe_timer > 0.0:
		return
	hp -= damage
	if hp <= 0:
		die()
		return
	is_stunned = true
	hit_stun_timer = hit_stun_duration
	iframe_timer = iframe_duration
	flash_timer = flash_interval

func die() -> void:
	queue_free()
