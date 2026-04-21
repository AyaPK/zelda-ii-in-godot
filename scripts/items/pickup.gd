class_name Pickup extends StaticBody2D

@export var collected_flag: String

func _ready() -> void:
	if collected_flag:
		if StoryFlags.get_flag(collected_flag):
			queue_free()

func collect() -> void:
	pass

func kill() -> void:
	if collected_flag:
		StoryFlags.set_flag(collected_flag, true)
	queue_free()

func _on_area_body_entered(body: Node2D) -> void:
	if body is LinkSidescroll:
		collect()
