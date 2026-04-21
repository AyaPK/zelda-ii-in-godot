class_name KoboldEnemy extends WalkForwardEnemy

const BOUNCE_SPEED_Y: float = -140.0

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_on_floor() and not is_stunned:
		velocity.y = BOUNCE_SPEED_Y
