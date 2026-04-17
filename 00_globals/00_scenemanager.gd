extends Node

var level: Node2D
var hud: Hud
var overworld_has_enemies: bool = false

var overworld_area: String = "Northwest Hyrule"
var pre_encounter_pos: Vector2

# [area_name][area_type][difficulty] -> scene path
const ENCOUNTER_SCENES: Dictionary = {
	"Northwest Hyrule": {
		"path":		{},
		"field":	{ "easy": "res://levels/encounters/northwest_hyrule/field_easy.tscn",    "hard": "res://levels/encounters/northwest_hyrule/field_hard.tscn",    "fairy": "res://levels/encounters/northwest_hyrule/field_fairy.tscn" },
		"forest":	{ "easy": "res://levels/encounters/northwest_hyrule/forest_easy.tscn",   "hard": "res://levels/encounters/northwest_hyrule/forest_hard.tscn",   "fairy": "res://levels/encounters/northwest_hyrule/forest_fairy.tscn" },
		"swamp":	{ "easy": "res://levels/encounters/northwest_hyrule/swamp_easy.tscn",    "hard": "res://levels/encounters/northwest_hyrule/swamp_hard.tscn",    "fairy": "res://levels/encounters/northwest_hyrule/swamp_fairy.tscn" },
		"graveyard":{ "easy": "res://levels/encounters/northwest_hyrule/graveyard_easy.tscn","hard": "res://levels/encounters/northwest_hyrule/graveyard_hard.tscn","fairy": "res://levels/encounters/northwest_hyrule/graveyard_fairy.tscn" },
		"desert":	{ "easy": "res://levels/encounters/northwest_hyrule/desert_easy.tscn","hard": "res://levels/encounters/northwest_hyrule/desert_hard.tscn","fairy": "res://levels/encounters/northwest_hyrule/desert_fairy.tscn" },
	},
}

var scene_path_string: String
var target_transition: String

signal transitioned
signal faded_in

var prev_scene: String
var prev_position: Vector2
var prev_direction: Vector2

func change_scene_to_encounter(area_type: String, difficulty: String) -> void:
	var area_map: Dictionary = ENCOUNTER_SCENES.get(overworld_area, {})
	var type_map: Dictionary = area_map.get(area_type, {})
	var scene_path: String = type_map.get(difficulty, "")
	pre_encounter_pos = get_tree().get_first_node_in_group("overworld-player").global_position
	get_tree().get_first_node_in_group("overworld-player").queue_free()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	transitioned.emit()
	faded_in.emit()

func change_scene_to_level(scene_path: String, target_node_name: String, facing_direction: String) -> void:
	if get_tree().get_first_node_in_group("overworld-player"):
		get_tree().get_first_node_in_group("overworld-player").queue_free()
	scene_path_string = scene_path
	target_transition = target_node_name
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().get_first_node_in_group("sidescroll-player").facing_right = (facing_direction == "Right")
	if target_node_name:
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

func leave_encounter_to_overworld() -> void:
	call_deferred("_do_leave_encounter_to_overworld")

func _do_leave_encounter_to_overworld() -> void:
	overworld_has_enemies = false
	get_tree().change_scene_to_file("res://levels/overworld.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().get_first_node_in_group("overworld-player").global_position = pre_encounter_pos
	transitioned.emit()
	faded_in.emit()
