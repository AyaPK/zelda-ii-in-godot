class_name Pickup extends CharacterBody2D

@export var collected_flag: String

var _landed: bool = false

func _ready() -> void:
	if collected_flag:
		if StoryFlags.get_flag(collected_flag):
			queue_free()

func _physics_process(delta: float) -> void:
	if _landed:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		_landed = true

func collect() -> void:
	pass

func kill() -> void:
	if collected_flag:
		StoryFlags.set_flag(collected_flag, true)
	queue_free()

func _on_area_body_entered(body: Node2D) -> void:
	if body is LinkSidescroll:
		collect()
