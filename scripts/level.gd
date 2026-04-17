class_name Level extends Node2D

@export var music: String
@export var is_dark: bool = false

const HUD = preload("uid://lkswdyu3i5wj")

func _ready() -> void:
	Scenemanager.level = self
	AudioManager.play_music(music)
	var hud = HUD.instantiate()
	add_child(hud)
	
	if is_dark:
		if StoryFlags.get_flag("got_candle"):
			make_light()
		else:
			make_dark()

func make_light() -> void:
	if $LightTiles:
		$LightTiles.show()
		$DarkTiles.hide()

func make_dark() -> void:
	if $LightTiles:
		$LightTiles.hide()
		$DarkTiles.show()
