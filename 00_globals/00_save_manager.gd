extends Node

const SAVE_PATH := "user://save_slot_%d.json"
const NORTH_PALACE := "res://levels/palaces/north_palace.tscn"
const SAVE_VERSION := 1

var active_slot: int = -1

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH % slot)

func get_slot_info(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {}
	var file := FileAccess.open(SAVE_PATH % slot, FileAccess.READ)
	if file == null:
		return {}
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	if data == null:
		return {}
	return {
		"name": data.get("name", "---"),
		"levels": data.get("player", {}).get("levels", {}),
	}

func new_game(slot: int, save_name: String) -> void:
	active_slot = slot
	PlayerManager.reset()
	StoryFlags.reset()
	_write_save(slot, save_name)

func save(slot: int) -> void:
	var save_name: String = get_slot_info(slot).get("name", "")
	_write_save(slot, save_name)

func load_slot(slot: int) -> void:
	if not slot_exists(slot):
		return
	var file := FileAccess.open(SAVE_PATH % slot, FileAccess.READ)
	if file == null:
		return
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	if data == null:
		return
	active_slot = slot
	PlayerManager.from_dict(data.get("player", {}))
	StoryFlags.from_dict(data.get("story_flags", {}))
	PlayerManager.current_hp = PlayerManager.max_hp
	Scenemanager.change_scene_to_level(NORTH_PALACE, "GameStart", "Right")

func autosave() -> void:
	if active_slot == -1:
		return
	print("[SaveManager] Autosaving to slot ", active_slot)
	save(active_slot)

func delete_slot(slot: int) -> void:
	if slot_exists(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH % slot))

func _write_save(slot: int, save_name: String) -> void:
	var data := {
		"version": SAVE_VERSION,
		"name": save_name,
		"player": PlayerManager.to_dict(),
		"story_flags": StoryFlags.to_dict(),
	}
	var file := FileAccess.open(SAVE_PATH % slot, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
