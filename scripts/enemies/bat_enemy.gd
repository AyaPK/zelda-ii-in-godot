class_name BatEnemy extends EncounterEnemy

enum State { HANG, DIVE, FLY, RETURN }

const FLY_SPEED: float = 60.0
const AGGRO_RANGE: float = 120.0
const FLY_DURATION: float = 2.0
const DIVE_DISTANCE: float = 16.0
const SINE_FREQ: float = 6.0
const SINE_AMP: float = 30.0

var state: State = State.HANG
var state_timer: float = 0.0
var fly_timer: float = 0.0
var roost_y: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	roost_y = global_position.y
	animation_player.play("hang")

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("sidescroll-player")

	match state:
		State.HANG:
			velocity = Vector2.ZERO
			if player and global_position.distance_to(player.global_position) <= AGGRO_RANGE:
				_enter_state(State.DIVE)

		State.DIVE:
			velocity += get_gravity() * delta
			velocity.x = 0.0
			if global_position.y >= roost_y + DIVE_DISTANCE:
				_enter_state(State.FLY)

		State.FLY:
			fly_timer += delta
			state_timer -= delta
			if player:
				var base_dir = (player.global_position - global_position).normalized()
				var sine_offset := Vector2(0.0, sin(fly_timer * SINE_FREQ) * SINE_AMP)
				velocity = base_dir * FLY_SPEED + sine_offset
				$Sprite2D.flip_h = velocity.x > 0.0
			if state_timer <= 0.0:
				_enter_state(State.RETURN)

		State.RETURN:
			fly_timer += delta
			var sine_offset := Vector2(sin(fly_timer * SINE_FREQ) * SINE_AMP, 0.0)
			velocity = Vector2(0.0, -FLY_SPEED) + sine_offset
			if global_position.y <= roost_y:
				global_position.y = roost_y
				_enter_state(State.HANG)

	move_and_slide()

func _enter_state(next: State) -> void:
	state = next
	match state:
		State.HANG:
			velocity = Vector2.ZERO
			animation_player.play("hang")
			var player := get_tree().get_first_node_in_group("sidescroll-player")
			if player and global_position.distance_to(player.global_position) <= AGGRO_RANGE:
				_enter_state(State.DIVE)
		State.DIVE:
			fly_timer = 0.0
			animation_player.play("fly")
		State.FLY:
			state_timer = FLY_DURATION
			animation_player.play("fly")
		State.RETURN:
			animation_player.play("fly")
