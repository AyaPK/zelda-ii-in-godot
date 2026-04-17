extends Node

var palaces_complete: Array[int] = []
var town_spells_learned: Dictionary = {}
var custom_flags: Dictionary = {
	"got_candle": false,
}

func reset() -> void:
	palaces_complete.clear()
	town_spells_learned.clear()
	custom_flags.clear()

func set_palace_complete(palace_id: int) -> void:
	if palace_id not in palaces_complete:
		palaces_complete.append(palace_id)

func is_palace_complete(palace_id: int) -> bool:
	return palace_id in palaces_complete

func set_town_spell(town: String, spell: String) -> void:
	town_spells_learned[town] = spell

func get_town_spell(town: String) -> String:
	return town_spells_learned.get(town, "")

func set_flag(key: String, value: bool) -> void:
	custom_flags[key] = value

func get_flag(key: String) -> bool:
	return custom_flags.get(key, false)

func to_dict() -> Dictionary:
	return {
		"palaces_complete": palaces_complete.duplicate(),
		"town_spells_learned": town_spells_learned.duplicate(),
		"custom_flags": custom_flags.duplicate(),
	}

func from_dict(d: Dictionary) -> void:
	palaces_complete = Array(d.get("palaces_complete", []), TYPE_INT, "", null)
	town_spells_learned = d.get("town_spells_learned", {})
	custom_flags = d.get("custom_flags", {})
