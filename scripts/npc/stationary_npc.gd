class_name StationaryNPC extends CharacterBody2D

@export var dialogue: String = ""
@export var sprite: Texture2D

@onready var interact_area: NPCInteractArea = $InteractArea

func _ready() -> void:
	$Sprite2D.texture = sprite
