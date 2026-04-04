class_name CameraBoundaryLeft extends Marker2D

func _ready() -> void:
	var player: LinkSidescroll = get_tree().get_first_node_in_group("sidescroll-player")
	player.camera.limit_left = int(global_position.x)
