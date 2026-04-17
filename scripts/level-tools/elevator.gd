extends Node2D

var functioning: bool = false
var player: LinkSidescroll

@export var high_y: float = -9999
@export var low_y: float = 9999

func _ready() -> void:
	player = get_tree().get_first_node_in_group("sidescroll-player")

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
