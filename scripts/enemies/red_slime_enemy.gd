class_name RedSlimeEnemy extends EncounterEnemy

enum State { CRAWL, SHUDDER, TURN }

const CRAWL_SPEED: float = 10.0
const SHUDDER_MIN: float = 0.8
const SHUDDER_MAX: float = 1.5
const CRAWL_MIN: float = 1.0
const CRAWL_MAX: float = 3.0

var state: State = State.CRAWL
var state_timer: float = 0.0
var walk_right: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	state_timer = randf_range(CRAWL_MIN, CRAWL_MAX)
	animation_player.play("crawl")

func _physics_process(delta: float) -> void:
	state_timer -= delta
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		State.CRAWL:
			velocity.x = CRAWL_SPEED if walk_right else -CRAWL_SPEED
			if state_timer <= 0.0:
				_enter_state(State.SHUDDER)
		State.SHUDDER:
			velocity.x = 0.0
			if state_timer <= 0.0:
				_enter_state(State.TURN)
		State.TURN:
			walk_right = randf() < 0.5
			_enter_state(State.CRAWL)

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
			animation_player.play("shudder")
		State.TURN:
			state_timer = 0.0
