class_name MoblinSpear extends Area2D

const SPEAR_SPEED: float = 120.0
const SPEAR_GRAVITY: float = 300.0
const DESPAWN_TIME: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	velocity = direction * SPEAR_SPEED
	$Sprite2D.flip_h = direction.x > 0.0

	var timer := Timer.new()
	timer.wait_time = DESPAWN_TIME
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _process(delta: float) -> void:
	velocity.y += SPEAR_GRAVITY * delta
	position += velocity * delta
	rotation = velocity.angle()
