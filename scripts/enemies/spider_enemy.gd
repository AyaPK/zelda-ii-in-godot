class_name SpiderEnemy extends EncounterEnemy

enum State { CRAWL, DROP, RETRACT }

@export var crawl_speed: float = 30.0
@export var drop_speed: float = 120.0
@export var retract_speed: float = 60.0
@export var aggro_range_x: float = 12.0
@export var drop_distance: float = 160.0
@export var patrol_half_width: float = 48.0

var state: State = State.CRAWL
var crawl_dir: float = 1.0
var ceiling_y: float = 0.0
var patrol_origin_x: float = 0.0
var _initialized: bool = false
var _web_line: Line2D = null
var _web_bottom_y: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	animation_player.play("crawl")
	_web_line = Line2D.new()
	_web_line.width = 1.0
	_web_line.default_color = Color.WHITE
	_web_line.z_index = 1
	get_parent().add_child(_web_line)

func _physics_process(delta: float) -> void:
	if not _initialized:
		ceiling_y = global_position.y
		patrol_origin_x = global_position.x
		_initialized = true

	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player := get_tree().get_first_node_in_group("sidescroll-player")

	match state:
		State.CRAWL:
			if global_position.x >= patrol_origin_x + patrol_half_width:
				global_position.x = patrol_origin_x + patrol_half_width
				crawl_dir = -1.0
				$Sprite2D.flip_h = false
			elif global_position.x <= patrol_origin_x - patrol_half_width:
				global_position.x = patrol_origin_x - patrol_half_width
				crawl_dir = 1.0
				$Sprite2D.flip_h = true
			velocity = Vector2(crawl_speed * crawl_dir, 0.0)
			if player and abs(player.global_position.x - global_position.x) <= aggro_range_x:
				_enter_state(State.DROP)

		State.DROP:
			velocity = Vector2(0.0, drop_speed)
			_web_line.clear_points()
			_web_line.add_point(get_parent().to_local(Vector2(global_position.x, ceiling_y)))
			_web_line.add_point(get_parent().to_local(global_position))
			if is_on_floor() or is_on_wall() or global_position.y >= ceiling_y + drop_distance:
				_enter_state(State.RETRACT)

		State.RETRACT:
			velocity = Vector2(0.0, -retract_speed)
			_web_line.clear_points()
			_web_line.add_point(get_parent().to_local(Vector2(global_position.x, ceiling_y)))
			_web_line.add_point(get_parent().to_local(global_position))
			if global_position.y <= ceiling_y:
				global_position.y = ceiling_y
				_enter_state(State.CRAWL)

	move_and_slide()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_web_line):
		_web_line.queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	var player := area.get_parent() as LinkSidescroll
	if player:
		hit_player(player)

func _enter_state(next: State) -> void:
	state = next
	match state:
		State.CRAWL:
			_web_line.clear_points()
			_web_line.queue_free()
			_web_line = Line2D.new()
			_web_line.width = 1.0
			_web_line.default_color = Color.WHITE
			_web_line.z_index = -1
			get_parent().add_child(_web_line)
			animation_player.play("crawl")
		State.DROP:
			ceiling_y = global_position.y
			animation_player.play("drop")
		State.RETRACT:
			_web_bottom_y = global_position.y
			animation_player.play("drop")
