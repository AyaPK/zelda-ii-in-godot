class_name BlueSlimeEnemy extends EncounterEnemy

enum State { CRAWL, SHUDDER, JUMP, CROUCH }

const CRAWL_SPEED: float = 10.0
const JUMP_SPEED_X: float = 80.0
const JUMP_SPEED_Y: float = -160.0
const SHUDDER_MIN: float = 0.6
const SHUDDER_MAX: float = 1.2
const JUMP_COUNT_MIN: int = 1
const JUMP_COUNT_MAX: int = 4
const CROUCH_DURATION: float = 0.2
const CRAWL_MIN: float = 1.0
const CRAWL_MAX: float = 2.0
const DIRECTION_TICK: float = 0.1

var state: State = State.CRAWL
var state_timer: float = 0.0
var walk_right: bool = true
var direction_timer: float = 0.0
var jumps_remaining: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	state_timer = randf_range(CRAWL_MIN, CRAWL_MAX)
	animation_player.play("crawl")
	_update_direction()

func _physics_process(delta: float) -> void:
	if is_stunned:
		velocity.x = 0.0
		velocity.y = 0.0
		move_and_slide()
		return
	state_timer -= delta
	direction_timer -= delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		State.CRAWL:
			if direction_timer <= 0.0:
				_update_direction()
				direction_timer = DIRECTION_TICK
			velocity.x = CRAWL_SPEED if walk_right else -CRAWL_SPEED
			if state_timer <= 0.0:
				_enter_state(State.SHUDDER)
		State.SHUDDER:
			velocity.x = 0.0
			if state_timer <= 0.0:
				_enter_state(State.JUMP)
		State.JUMP:
			if is_on_floor() and state_timer < 0.0:
				if jumps_remaining > 0:
					_enter_state(State.CROUCH)
				else:
					_enter_state(State.CRAWL)
		State.CROUCH:
			velocity.x = 0.0
			if state_timer <= 0.0:
				_enter_state(State.JUMP)

	$Sprite2D.flip_h = walk_right
	move_and_slide()

func _enter_state(next: State) -> void:
	state = next
	match state:
		State.CRAWL:
			state_timer = randf_range(CRAWL_MIN, CRAWL_MAX)
			animation_player.play("crawl")
		State.SHUDDER:
			state_timer = randf_range(SHUDDER_MIN, SHUDDER_MAX)
			jumps_remaining = randi_range(JUMP_COUNT_MIN, JUMP_COUNT_MAX)
			animation_player.play("shudder")
		State.JUMP:
			state_timer = 0.1
			_update_direction()
			velocity.x = JUMP_SPEED_X if walk_right else -JUMP_SPEED_X
			velocity.y = JUMP_SPEED_Y
			animation_player.play("jump")
			jumps_remaining -= 1
		State.CROUCH:
			state_timer = CROUCH_DURATION
			animation_player.play("crouch")

func _update_direction() -> void:
	var player := get_tree().get_first_node_in_group("sidescroll-player")
	if player:
		walk_right = player.global_position.x > global_position.x
