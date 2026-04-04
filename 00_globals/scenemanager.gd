extends Node

var level: Node2D

var scene_path_string: String
var target_transition: String

signal transitioned
signal faded_in

var prev_scene: String
var prev_position: Vector2
var prev_direction: Vector2

func change_scene_to_level(scene_path: String, target_node_name: String, facing_direction: String) -> void:
	get_tree().get_first_node_in_group("overworld-player").queue_free()
	scene_path_string = scene_path
	target_transition = target_node_name
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	get_tree().get_first_node_in_group("sidescroll-player").facing_right = (facing_direction == "Right")
	get_tree().get_first_node_in_group("sidescroll-player").global_position = level.get_node(target_node_name).global_position
	transitioned.emit()
	faded_in.emit()

func change_scene_to_overworld(target_node_name: String) -> void:
	call_deferred("_do_change_scene_to_overworld", target_node_name)

func _do_change_scene_to_overworld(target_node_name: String) -> void:
	target_transition = target_node_name
	get_tree().change_scene_to_file("res://levels/overworld.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().get_first_node_in_group("overworld-player").global_position = level.get_node(target_node_name).global_position
	transitioned.emit()
	faded_in.emit()
