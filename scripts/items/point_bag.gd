class_name PointBag extends Pickup

@export var exp_gain: int = 50
var collected: bool = false

func collect() -> void:
	$Label.text = str(exp_gain)
	$Sprite2D.hide()
	$LabelAnim.play("appear")

func _on_area_body_entered(body: Node2D) -> void:
	super(body)
	collected = true

func _on_label_anim_animation_finished(anim_name: StringName) -> void:
	if collected:
		PlayerManager.add_xp(exp_gain)
		kill()
