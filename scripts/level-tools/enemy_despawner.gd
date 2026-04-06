class_name EnemyDespawner extends Node2D


func _on_despawn_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("sidescroll-enemy"):
		body.queue_free()
