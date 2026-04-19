extends Node2D

var functioning: bool = false
var player: LinkSidescroll

@export var high_y: float = -9999
@export var low_y: float = 9999
@onready var link_check: Area2D = $LinkCheck

func _ready() -> void:
	player = get_tree().get_first_node_in_group("sidescroll-player")
	Signals.level_finished_loading.connect(check_for_link)

func _process(delta: float) -> void:
	if functioning:
		if Input.is_action_pressed("crouch") and !global_position.y >= low_y:
			global_position.y += 1
			player.global_position.y += 1
		elif Input.is_action_pressed("move_up") and !global_position.y <= high_y:
			global_position.y -= 1.4

func _on_standing_area_body_entered(body: Node2D) -> void:
	functioning = true
	player.on_elevator = true

func _on_standing_area_body_exited(body: Node2D) -> void:
	functioning = false
	player.on_elevator = false

func check_for_link() -> void:
	if not player:
		return
	var shape := link_check.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape == null:
		return
	var rect_shape := shape.shape as RectangleShape2D
	if rect_shape == null:
		return
	var rect := Rect2(shape.global_position - rect_shape.size * 0.5, rect_shape.size)
	if rect.has_point(player.global_position):
		move_to_link(player)
		

func move_to_link(body: LinkSidescroll) -> void:
	global_position.y = body.global_position.y-14
