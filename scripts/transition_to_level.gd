class_name TransitionToLevel extends Interactable

@export_file("*.tscn") var target_scene: String
@export var node_name: String

func activate() -> void:
	Scenemanager.change_scene_to_level(target_scene, node_name)

func _on_body_entered(_body: Node2D) -> void:
	var player: LinkOverworld = get_tree().get_first_node_in_group("overworld-player")
	player.interactable = self

func _on_body_exited(_body: Node2D) -> void:
	var player: LinkOverworld = get_tree().get_first_node_in_group("overworld-player")
	player.interactable = null
