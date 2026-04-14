extends Node

signal xp_changed(new_xp: int)
signal level_up_available
signal extra_life

const THRESHOLDS: Dictionary = {
	"life":   [0, 50,  150,  400,  800,  1500, 2500, 4000],
	"magic":  [0, 100, 300,  700,  1200, 2200, 3500, 6000],
	"attack": [0, 200, 500,  1000, 2000, 3000, 5000, 8000],
}

var xp: int = 0
var levels: Dictionary = { "life": 1, "magic": 1, "attack": 1}
var pending_levelups: int = 0

var life_level: int:
	get:
		return levels["life"]
var magic_level: int:
	get:
		return levels["magic"]
var attack_level: int:
	get:
		return levels["attack"]

var lives: int = 3
var max_hp: int :
	get:
		return 64 + (heart_containers * 16)
var current_hp: int = 72
var max_magic: int = 32
var magic: int = 32

var heart_containers: int = 0

var spells: Array[String] = []
var items: Array[String] = []
var containers: int = 0
var magic_containers: int = 0

func has_spell(spell: String) -> bool:
	return spell in spells

func has_item(item: String) -> bool:
	return item in items

func add_spell(spell: String) -> void:
	if not has_spell(spell):
		spells.append(spell)

func add_item(item: String) -> void:
	if not has_item(item):
		items.append(item)

func add_xp(amount: int) -> void:
	if _all_maxed():
		extra_life.emit()
		return
	xp += amount
	xp_changed.emit(xp)
	var gained := _check_thresholds()
	for i in gained:
		pending_levelups += 1
		level_up_available.emit()

func apply_level_up(track: String) -> void:
	if pending_levelups <= 0:
		return
	if levels[track] >= 8:
		return
	levels[track] += 1
	pending_levelups -= 1

func reset() -> void:
	xp = 0
	levels = { "life": 1, "magic": 1, "attack": 1 }
	pending_levelups = 0
	lives = 3
	max_hp = 4
	current_hp = 4
	max_magic = 32
	magic = 32
	spells.clear()
	items.clear()
	containers = 0
	magic_containers = 0

func on_player_death() -> void:
	xp = 0
	pending_levelups = 0
	xp_changed.emit(xp)

func to_dict() -> Dictionary:
	return {
		"xp": xp,
		"levels": levels.duplicate(),
		"pending_levelups": pending_levelups,
		"lives": lives,
		"max_hp": max_hp,
		"current_hp": current_hp,
		"max_magic": max_magic,
		"magic": magic,
		"spells": spells.duplicate(),
		"items": items.duplicate(),
		"containers": containers,
		"magic_containers": magic_containers,
	}

func from_dict(d: Dictionary) -> void:
	xp = d.get("xp", 0)
	levels = d.get("levels", { "life": 1, "magic": 1, "attack": 1 })
	pending_levelups = d.get("pending_levelups", 0)
	lives = d.get("lives", 3)
	max_hp = d.get("max_hp", 4)
	current_hp = d.get("current_hp", 4)
	max_magic = d.get("max_magic", 32)
	magic = d.get("magic", 32)
	spells = Array(d.get("spells", []), TYPE_STRING, "", null)
	items = Array(d.get("items", []), TYPE_STRING, "", null)
	containers = d.get("containers", 0)
	magic_containers = d.get("magic_containers", 0)

func xp_to_next(track: String) -> int:
	var lv: int = levels[track]
	if lv >= 8:
		return 0
	return THRESHOLDS[track][lv - 1]

func _check_thresholds() -> int:
	var gained := 0
	for track in levels:
		var lv: int = levels[track]
		while lv < 8 and xp >= THRESHOLDS[track][lv - 1]:
			lv += 1
			gained += 1
		levels[track] = lv
	return gained

func _all_maxed() -> bool:
	for track in levels:
		if levels[track] < 8:
			return false
	return true
