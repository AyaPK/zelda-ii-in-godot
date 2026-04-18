class_name FlyingRockSpawner extends Node2D

@export_file("*.tscn") var rock_scene: String
@export var pool_size: int = 4
@export var spawn_interval: float = 2.0
@export var rock_speed: float = 80.0
@export var y_min: float = -80.0
@export var y_max: float = -32.0

var _pool: Array[FlyingRock] = []
var _timer: float = 0.0

func _ready() -> void:
	if rock_scene.is_empty():
		return
	var scene := load(rock_scene) as PackedScene
	for i in pool_size:
		var rock: FlyingRock = scene.instantiate()
		rock.move_speed = rock_speed
		add_child(rock)
		rock.deactivate()
		_pool.append(rock)
	print(rock_scene)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_launch_rock()

func _launch_rock() -> void:
	var rock := _get_inactive_rock()
	if rock == null:
		return

	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	if not player:
		return

	var cam := player.camera
	var half_w := get_viewport_rect().size.x / 2.0 / cam.zoom.x
	var cam_x := clampf(cam.global_position.x, cam.limit_left + half_w, cam.limit_right - half_w)

	var dir := 1.0 if randf() < 0.5 else -1.0
	var spawn_x := cam_x + (-half_w - 16.0) if dir > 0.0 else cam_x + (half_w + 16.0)
	var spawn_y := global_position.y + randf_range(y_min, y_max)

	rock.activate(Vector2(spawn_x, spawn_y), dir)

func _get_inactive_rock() -> FlyingRock:
	for rock in _pool:
		if rock.process_mode == Node.PROCESS_MODE_DISABLED:
			return rock
	return null
