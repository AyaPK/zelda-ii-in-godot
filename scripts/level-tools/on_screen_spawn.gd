class_name OnScreenSpawner extends Node2D

@export_file("*.tscn") var enemy_to_spawn: String
var enemy_alive: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_is_on_screen_screen_entered() -> void:
	if !enemy_alive:
		var enemy = load(enemy_to_spawn).instantiate()
		Scenemanager.level.add_child(enemy)
		enemy.global_position = global_position
		enemy.spawner = self
		enemy_alive = true
	pass
