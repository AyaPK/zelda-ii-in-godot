class_name TransitionToLevel extends Interactable

@export_file("*.tscn") var target_scene: String
@export var node_name: String
@export_enum("Left", "Right") var facing_direction = "Left"

func activate() -> void:
	Scenemanager.change_scene_to_level(target_scene, node_name, facing_direction)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("overworld-player"):
		var player: LinkOverworld = get_tree().get_first_node_in_group("overworld-player")
		player.interactable = self

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("overworld-player"):
		var player: LinkOverworld = get_tree().get_first_node_in_group("overworld-player")
		player.interactable = null
