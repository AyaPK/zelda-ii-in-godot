class_name WalkingNPC extends CharacterBody2D

@export var dialogue: String = ""
@export var sprite: Texture2D
@export var speed: float = 40.0
@export var walk_right: bool = true
@export var despawn_x: float = 0.0
@export var respawn_delay: float = 3.0

var _spawn_position: Vector2
var _timer: float = 0.0
var _waiting: bool = false

@onready var interact_area: NPCInteractArea = $InteractArea

func _ready() -> void:
	$Sprite2D.texture = sprite
	$Sprite2D.flip_h = walk_right
	_spawn_position = global_position

func _physics_process(delta: float) -> void:
	if interact_area.is_talking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _waiting:
		_timer -= delta
		if _timer <= 0.0:
			_waiting = false
			_reset_position()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = speed if walk_right else -speed
	move_and_slide()

	var past_despawn := global_position.x >= despawn_x if walk_right else global_position.x <= despawn_x
	if past_despawn:
		$Sprite2D.hide()
		velocity = Vector2.ZERO
		_waiting = true
		_timer = respawn_delay

func _reset_position() -> void:
	global_position = _spawn_position
	$Sprite2D.show()
