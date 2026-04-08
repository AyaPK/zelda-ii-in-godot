class_name SpearMoblinEnemy extends EncounterEnemy

const SPEAR_SCENE: PackedScene = preload("res://scenes/enemies/level/moblin_spear.tscn")

const WALK_SPEED: float = 60.0
const PACE_SPEED: float = 40.0
const PACE_FLIP_MIN: float = 20
const PACE_FLIP_MAX: float = 30
const THROW_RANGE: float = 80.0
const HALT_DURATION: float = 0.6

enum State { WALK, HALT, THROW, PACE }

var state: State = State.WALK
var state_timer: float = 0.0
var facing_right: bool = true
var pace_right: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("walk")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var player := get_tree().get_first_node_in_group("sidescroll-player")

	match state:
		State.WALK:
			if player:
				facing_right = player.global_position.x > global_position.x
				if global_position.distance_to(player.global_position) <= THROW_RANGE:
					_enter_state(State.HALT)
				else:
					velocity.x = WALK_SPEED if facing_right else -WALK_SPEED
			$Sprite2D.flip_h = facing_right

		State.HALT:
			velocity.x = 0.0
			state_timer -= delta
			if state_timer <= 0.0:
				_enter_state(State.THROW)

		State.THROW:
			velocity.x = 0.0
			if not animation_player.is_playing():
				_enter_state(State.PACE)

		State.PACE:
			state_timer -= delta
			if state_timer <= 0.0:
				pace_right = !pace_right
				state_timer = randf_range(PACE_FLIP_MIN, PACE_FLIP_MAX)
			velocity.x = PACE_SPEED if pace_right else -PACE_SPEED
			if player and global_position.distance_to(player.global_position) > THROW_RANGE:
				_enter_state(State.WALK)
			elif player:
				_enter_state(State.HALT)

	move_and_slide()

func _enter_state(next: State) -> void:
	state = next
	match state:
		State.WALK:
			animation_player.play("walk")
			var player := get_tree().get_first_node_in_group("sidescroll-player")
			if player and global_position.distance_to(player.global_position) <= THROW_RANGE:
				_enter_state(State.HALT)
		State.PACE:
			state_timer = randf_range(PACE_FLIP_MIN, PACE_FLIP_MAX)
			animation_player.play("walk")
		State.HALT:
			state_timer = HALT_DURATION
			animation_player.play("halt")
		State.THROW:
			animation_player.play("throw")
			_spawn_spear()

func _spawn_spear() -> void:
	var spear: MoblinSpear = SPEAR_SCENE.instantiate()
	spear.global_position = global_position
	spear.direction = Vector2.RIGHT if facing_right else Vector2.LEFT
	get_parent().add_child(spear)
