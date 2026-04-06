extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("sidescroll-player"):
		Scenemanager.leave_encounter_to_overworld()
