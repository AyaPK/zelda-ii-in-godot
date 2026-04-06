extends Node2D

@export_file("*.tscn") var enemy_scene: String
@export var frequency: float = 0.0
@export var start_offset: float = 0.0
@export_enum("String", "right", "left") var walk_direction: String

var offset: int
var timer_offset_enabled: bool = false

func _ready() -> void:
	if frequency > 0:
		$Timer.wait_time = frequency + start_offset
		timer_offset_enabled = true
		$Timer.start()
	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	offset = 128+16 if walk_direction == "left" else -128-16
	global_position = player.camera.global_position + Vector2(offset, 0)

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	if player:
		global_position = player.camera.global_position + Vector2(offset, 0)

func _on_timer_timeout() -> void:
	if timer_offset_enabled:
		timer_offset_enabled = false
		$Timer.wait_time = frequency
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scene.is_empty():
		return
	var scene := load(enemy_scene) as PackedScene
	if scene == null:
		return
	var enemy: WalkForwardEnemy = scene.instantiate()
	enemy.walk_right = walk_direction == "right"
	enemy.global_position = global_position
	get_parent().add_child.call_deferred(enemy)
