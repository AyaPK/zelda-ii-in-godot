class_name Overworld extends Node2D

func _ready() -> void:
	Scenemanager.level = self
	AudioManager.play_music("overworld")
