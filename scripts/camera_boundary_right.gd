class_name CameraBoundaryRight extends Marker2D

func _ready() -> void:
	var player: LinkSidescroll = get_tree().get_first_node_in_group("sidescroll-player")
	player.camera.limit_right = int(global_position.x)
