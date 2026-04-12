extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.stop_music()
	%PlayerButton1.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_button_1_pressed() -> void:
	Scenemanager.change_scene_to_level("res://levels/palaces/north_palace.tscn", "GameStart", "right")

func _on_register_button_pressed() -> void:
	pass # Replace with function body.

func _on_delete_button_pressed() -> void:
	pass # Replace with function body.
