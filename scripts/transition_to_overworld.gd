extends Area2D

@export var node_to_transition_to: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("sidescroll-player"):
		Scenemanager.change_scene_to_overworld(node_to_transition_to)
		
