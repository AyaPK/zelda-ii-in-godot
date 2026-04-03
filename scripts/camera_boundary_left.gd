class_name CameraBoundaryLeft extends VisibleOnScreenNotifier2D

func _ready() -> void:
	var player: LinkSidescroll = get_tree().get_first_node_in_group("sidescroll-player")
	player.camera.limit_left = global_position.x

func _on_screen_entered() -> void:
	var player: LinkSidescroll = get_tree().get_first_node_in_group("sidescroll-player")
	player.camera.limit_left = global_position.x
