extends Node2D

@export_file("*.tscn") var enemy_scene: String
@export var frequency: float = 0.0

func _ready() -> void:
	if frequency > 0:
		$Timer.wait_time = frequency
		$Timer.start()
	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	global_position = player.camera.global_position + Vector2(128+16, 0)
	spawn_enemy()

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	if player:
		global_position = player.camera.global_position + Vector2(128+16, 0)

func _on_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scene.is_empty():
		return
	var scene := load(enemy_scene) as PackedScene
	if scene == null:
		return
	var enemy := scene.instantiate()
	enemy.global_position = global_position
	get_parent().add_child.call_deferred(enemy)
