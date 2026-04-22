class_name NPC extends CharacterBody2D

@export var dialogue: String = ""
@export var speed: float = 30.0
@export var waypoint_a: NodePath
@export var waypoint_b: NodePath
@export var wait_time: float = 1.0
@export var sprite: Texture2D

var _target: Marker2D
var _wait_timer: float = 0.0
var _waiting: bool = false

@onready var _wp_a: Marker2D = get_node(waypoint_a)
@onready var _wp_b: Marker2D = get_node(waypoint_b)
@onready var interact_area: NPCInteractArea = $InteractArea
@onready var _anim: AnimationPlayer = $Anim

func _ready() -> void:
	_target = _wp_b
	$Sprite2D.texture = sprite

func _physics_process(delta: float) -> void:
	if interact_area.is_talking:
		velocity = Vector2.ZERO
		_anim.play("idle")
		move_and_slide()
		return

	if _waiting:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_waiting = false
			_target = _wp_a if _target == _wp_b else _wp_b
		velocity = Vector2.ZERO
		_anim.play("idle")
		move_and_slide()
		return

	var diff := _target.global_position - global_position
	if diff.length() < 2.0:
		_waiting = true
		_wait_timer = wait_time
		return

	velocity = diff.normalized() * speed
	$Sprite2D.flip_h = velocity.x > 0.0
	_anim.play("walk")
	move_and_slide()
