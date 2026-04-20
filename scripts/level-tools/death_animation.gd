class_name DeathAnimation extends Node2D

@onready var player: AnimationPlayer = $AnimationPlayer
var xp_num: int
var show_label: bool = true
signal finished

func _ready() -> void:
	$Sprite2D.hide()
	$Label.hide()
	xp_num = get_parent().xp_value

func play() -> void:
	$Label.text = str(xp_num) if (xp_num > 0 and show_label) else ""
	$AnimationPlayer.play("play")
	$LabelAnim.play("appear")

func _on_label_anim_animation_finished(anim_name: StringName) -> void:
	finished.emit()
