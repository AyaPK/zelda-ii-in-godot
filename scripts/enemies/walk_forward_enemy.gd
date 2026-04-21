class_name WalkForwardEnemy extends EncounterEnemy

@export var SPEED = 60.0

var walk_right: bool = true

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	if is_stunned:
		velocity.x = 0.0
		move_and_slide()
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = SPEED if walk_right else -SPEED
	if velocity.x > 0:
		$Sprite2D.flip_h = true

	move_and_slide()
