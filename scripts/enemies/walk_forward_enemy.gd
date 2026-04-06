class_name WalkForwardEnemy extends EncounterEnemy

const SPEED = 60.0

var walk_right: bool = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = SPEED if walk_right else -SPEED
	if velocity.x > 0:
		$Sprite2D.flip_h = true

	move_and_slide()
