class_name OverworldEnemy extends CharacterBody2D

var tilemap: TileMapLayer
@export var move_speed: float = 64.0
@export var initial_direction: Vector2i = Vector2i.RIGHT

const easy_sprite = preload("res://assets/art/sprites/overworld-blob.png")
const hard_sprite = preload("res://assets/art/sprites/overworld-moblin.png")

const STRAIGHT_CHANCE: float = 0.5
const ALL_DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

enum EnemyType { EASY, HARD, FAIRY }

var is_moving: bool = false
var target_position: Vector2
var current_direction: Vector2i = Vector2i.ZERO
var enemy_type: EnemyType = EnemyType.EASY

func _ready() -> void:
	tilemap = Scenemanager.level.get_node("Tilemap") as TileMapLayer
	if tilemap == null:
		push_error("OverworldEnemy: could not find Tilemap node on level.")
		set_process(false)
		return

	var roll := randf()
	if roll < 0.5:
		enemy_type = EnemyType.EASY
	elif roll < 0.9:
		enemy_type = EnemyType.HARD
		$Sprite2D.texture = hard_sprite
	else:
		enemy_type = EnemyType.FAIRY

	position = snap_to_tile_center(position)
	target_position = position
	current_direction = initial_direction
	_try_start_move()

func _process(delta: float) -> void:
	if is_moving:
		_move_toward_target(delta)

func _move_toward_target(delta: float) -> void:
	position = position.move_toward(target_position, move_speed * delta)
	if position.distance_to(target_position) < 0.01:
		position = target_position
		is_moving = false
		_decide_next_direction()
		_try_start_move()

func _decide_next_direction() -> void:
	var opposite: Vector2i = -current_direction

	if randf() < STRAIGHT_CHANCE:
		var next_cell := world_to_cell(position) + current_direction
		if is_cell_walkable(next_cell):
			return

	var candidates: Array[Vector2i] = []
	for dir in ALL_DIRECTIONS:
		if dir == opposite:
			continue
		if is_cell_walkable(world_to_cell(position) + dir):
			candidates.append(dir)

	if candidates.is_empty():
		if is_cell_walkable(world_to_cell(position) + opposite):
			current_direction = opposite
		return

	candidates.shuffle()
	current_direction = candidates[0]

func _try_start_move() -> void:
	var next_cell := world_to_cell(position) + current_direction
	if is_cell_walkable(next_cell):
		target_position = cell_to_world(next_cell)
		is_moving = true
	else:
		_decide_next_direction()
		next_cell = world_to_cell(position) + current_direction
		if is_cell_walkable(next_cell):
			target_position = cell_to_world(next_cell)
			is_moving = true

func is_cell_walkable(cell: Vector2i) -> bool:
	var tile_data := tilemap.get_cell_tile_data(cell)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("walkable") == true

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(world_pos))

func cell_to_world(cell: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(cell))

func snap_to_tile_center(world_pos: Vector2) -> Vector2:
	return cell_to_world(world_to_cell(world_pos))


func _on_despawn_timeout() -> void:
	Scenemanager.overworld_has_enemies = false
	queue_free()
