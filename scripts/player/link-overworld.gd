class_name LinkOverworld extends Node2D

@export var tilemap: TileMapLayer
@export var move_speed: float = 64.0

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/overworld/overworld_encounter.tscn")
const ENCOUNTER_CHANCE: float = 0.1
const ENCOUNTER_SPAWN_OFFSET: int = 5

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_moving: bool = false
var target_position: Vector2
var current_direction: Vector2i = Vector2i.ZERO
var buffered_direction: Vector2i = Vector2i.ZERO
var facing_direction: Vector2i = Vector2i.DOWN

var interactable: Interactable = null

# Stores currently held directions in press order.
# Last item = most recently pressed, which wins.
var held_directions: Array[Vector2i] = []

func _ready() -> void:
	if tilemap == null:
		push_error("tilemap is not assigned in the Inspector.")
		set_process(false)
		return

	position = snap_to_tile_center(position)
	target_position = position

	for entry in [["move_left", Vector2i.LEFT], ["move_right", Vector2i.RIGHT], ["move_up", Vector2i.UP], ["move_down", Vector2i.DOWN]]:
		if Input.is_action_pressed(entry[0]):
			held_directions.append(entry[1])

	update_animation()

func _process(delta: float) -> void:
	update_input_buffer()

	if is_moving:
		move_toward_target(delta)
	else:
		try_start_move()

	update_animation()
	
func update_input_buffer() -> void:
	handle_direction_input("move_left", Vector2i.LEFT)
	handle_direction_input("move_right", Vector2i.RIGHT)
	handle_direction_input("move_up", Vector2i.UP)
	handle_direction_input("move_down", Vector2i.DOWN)

	# Remove any stale entries just in case
	for i in range(held_directions.size() - 1, -1, -1):
		if not is_direction_still_held(held_directions[i]):
			held_directions.remove_at(i)

	if held_directions.size() > 0:
		buffered_direction = held_directions[held_directions.size() - 1]
	else:
		buffered_direction = Vector2i.ZERO

func handle_direction_input(action: String, dir: Vector2i) -> void:
	if Input.is_action_just_pressed(action):
		held_directions.erase(dir)
		held_directions.append(dir)

	if Input.is_action_just_released(action):
		held_directions.erase(dir)

func is_direction_still_held(dir: Vector2i) -> bool:
	match dir:
		Vector2i.LEFT:
			return Input.is_action_pressed("move_left")
		Vector2i.RIGHT:
			return Input.is_action_pressed("move_right")
		Vector2i.UP:
			return Input.is_action_pressed("move_up")
		Vector2i.DOWN:
			return Input.is_action_pressed("move_down")
		_:
			return false

func try_start_move() -> void:
	if buffered_direction == Vector2i.ZERO:
		current_direction = Vector2i.ZERO
		return

	var current_cell := world_to_cell(position)
	var next_cell := current_cell + buffered_direction

	var walkable := is_cell_walkable(next_cell)

	if walkable and not is_direction_blocked(buffered_direction):
		current_direction = buffered_direction
		facing_direction = current_direction
		target_position = cell_to_world(next_cell)
		is_moving = true
	else:
		# Still face the pressed direction even if blocked (feels nicer)
		facing_direction = buffered_direction

func is_direction_blocked(dir: Vector2i) -> bool:
	if dir == Vector2i.UP:
		return $RayUp.is_colliding()
	elif dir == Vector2i.DOWN:
		return $RayDown.is_colliding()
	elif dir == Vector2i.LEFT:
		return $RayLeft.is_colliding()
	elif dir == Vector2i.RIGHT:
		return $RayRight.is_colliding()
	
	return false

func move_toward_target(delta: float) -> void:
	position = position.move_toward(target_position, move_speed * delta)

	if position.distance_to(target_position) < 0.01:
		position = target_position
		is_moving = false
		on_end_step()
		try_continue_move()

func on_end_step() -> void:
	if interactable:
		interactable.activate()

	if !Scenemanager.overworld_has_enemies:
		var current_cell := world_to_cell(position)
		var tile_data := tilemap.get_cell_tile_data(current_cell)
		if tile_data and tile_data.get_custom_data("dangerous"):
			if randf() < ENCOUNTER_CHANCE:
				spawn_enemies()

func spawn_enemies() -> void:
	Scenemanager.overworld_has_enemies = true
	var current_cell := world_to_cell(position)
	var tile_data := tilemap.get_cell_tile_data(current_cell)
	var spawn_cell_1 := current_cell + Vector2i(ENCOUNTER_SPAWN_OFFSET, 0)
	var spawn_cell_2 := current_cell + Vector2i(-ENCOUNTER_SPAWN_OFFSET, 0)
	var spawn_cell_3 := current_cell + Vector2i(0, -ENCOUNTER_SPAWN_OFFSET)
	var enemy: OverworldEnemy = ENEMY_SCENE.instantiate()
	enemy.initial_direction = Vector2i.LEFT
	enemy.global_position = cell_to_world(spawn_cell_1)
	
	var enemy2: OverworldEnemy = ENEMY_SCENE.instantiate()
	enemy2.initial_direction = Vector2i.RIGHT
	enemy2.global_position = cell_to_world(spawn_cell_2)
	
	var enemy3: OverworldEnemy = ENEMY_SCENE.instantiate()
	enemy3.initial_direction = Vector2i.DOWN
	enemy3.global_position = cell_to_world(spawn_cell_3)
	Scenemanager.level.add_child(enemy)
	Scenemanager.level.add_child(enemy2)
	Scenemanager.level.add_child(enemy3)


func try_continue_move() -> void:
	if buffered_direction == Vector2i.ZERO:
		current_direction = Vector2i.ZERO
		return

	var current_cell := world_to_cell(position)
	var next_cell := current_cell + buffered_direction

	var walkable := is_cell_walkable(next_cell)

	# <- Added raycast check here
	if walkable and not is_direction_blocked(buffered_direction):
		current_direction = buffered_direction
		facing_direction = current_direction
		target_position = cell_to_world(next_cell)
		is_moving = true
	else:
		current_direction = Vector2i.ZERO
		facing_direction = buffered_direction

func update_animation() -> void:
	var anim_name := ""

	if is_moving:
		anim_name = "walk_" + direction_to_string(facing_direction)
	else:
		anim_name = "idle_" + direction_to_string(facing_direction)

	if animation_player.current_animation != anim_name or not animation_player.is_playing():
		animation_player.play(anim_name)

func direction_to_string(dir: Vector2i) -> String:
	match dir:
		Vector2i.LEFT:
			return "left"
		Vector2i.RIGHT:
			return "right"
		Vector2i.UP:
			return "up"
		_:
			return "down"

func is_cell_walkable(cell: Vector2i) -> bool:
	var tile_data := tilemap.get_cell_tile_data(cell)

	if tile_data == null:
		return false

	var walkable = tile_data.get_custom_data("walkable")
	return walkable == true

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local_pos := tilemap.to_local(world_pos)
	return tilemap.local_to_map(local_pos)

func cell_to_world(cell: Vector2i) -> Vector2:
	var local_pos := tilemap.map_to_local(cell)
	return tilemap.to_global(local_pos)

func snap_to_tile_center(world_pos: Vector2) -> Vector2:
	var cell := world_to_cell(world_pos)
	return cell_to_world(cell)
