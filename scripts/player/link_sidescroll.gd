class_name LinkSidescroll extends CharacterBody2D

@export var move_speed: float = 120.0
@export var jump_speed: float = 210.0
@export var gravity: float = 600.0
@export var max_fall_speed: float = 600.0
@export var friction: float = 600.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D

var facing_right: bool = true
var was_on_floor: bool = true
var landing_timer: float = 0.0
@export var landing_duration: float = 0.15

func _physics_process(delta: float) -> void:
	handle_input()
	apply_gravity(delta)
	move_and_slide()
	if not was_on_floor and is_on_floor():
		landing_timer = landing_duration
	if landing_timer > 0:
		landing_timer -= delta
	was_on_floor = is_on_floor()
	update_animation()

func handle_input() -> void:
	var input_dir: float = 0.0

	if Input.is_action_pressed("move_left"):
		input_dir -= 1
	if Input.is_action_pressed("move_right"):
		input_dir += 1

	if input_dir != 0:
		velocity.x = input_dir * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * get_physics_process_delta_time())

	if input_dir != 0:
		facing_right = input_dir > 0

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
	elif velocity.y > 0:
		velocity.y = 0

func update_animation() -> void:
	if not is_on_floor():
		if velocity.y < 0:
			play_animation("jump")
		else:
			play_animation("fall")
	elif landing_timer > 0:
		play_animation("land")
	elif velocity.x != 0:
		play_animation("run")
	else:
		play_animation("idle")
	$Sprite.scale.x = 1 if facing_right else -1

func play_animation(anim_name: String) -> void:
	if animation_player.current_animation != name:
		animation_player.play(anim_name)


func _on_camera_boundary_left_screen_entered() -> void:
	pass # Replace with function body.
