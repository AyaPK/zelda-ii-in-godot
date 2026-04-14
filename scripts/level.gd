class_name Level extends Node2D

@export var music: String

const HUD = preload("uid://lkswdyu3i5wj")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenemanager.level = self
	AudioManager.play_music(music)
	var hud = HUD.instantiate()
	add_child(hud)
