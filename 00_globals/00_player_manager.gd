extends Node

signal xp_changed(new_xp: int)
signal level_up_available
signal extra_life

const XP_MULT: int = 10

const THRESHOLDS: Dictionary = {
	"life":   [50,  150,  400,  800,  1500, 2500, 4000],
	"magic":  [100, 300,  700,  1200, 2200, 3500, 6000],
	"attack": [200, 500,  1000, 2000, 3000, 5000, 8000],
}

var xp: int = 0
var levels: Dictionary = { "life": 1, "magic": 1, "attack": 1}
var pending_levelups: int = 0
var pending_tracks: Array[String] = []
var deferred_threshold: int = 0

var life_level: int:
	get:
		return levels["life"]
var magic_level: int:
	get:
		return levels["magic"]
var attack_level: int:
	get:
		return levels["attack"]

var lives: int = 0
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

var enemy_kill_count: int = 0

const POINT_BAG_SCENE: String = "res://scenes/items/point_bag.tscn"
const BLUE_POTION_SCENE: String = "res://scenes/items/blue_potion.tscn"
const RED_POTION_SCENE: String = "res://scenes/items/red_potion.tscn"

## Called by non-boss enemies on death.
## Returns {"path": String, "exp_gain": int} for a bag, {"path": String} for a potion, or {} for no drop.
func register_enemy_kill(drop_table: String) -> Dictionary:
	if drop_table == "-":
		return {}
	enemy_kill_count += 1
	print("[PlayerManager] Enemy kill count: ", enemy_kill_count)
	if enemy_kill_count % 10 != 0:
		return {}
	var roll := randf()
	print("[PlayerManager] Drop triggered! Table: ", drop_table, " | Roll: ", roll)
	if drop_table == "A":
		if roll < 0.9:
			return {"path": BLUE_POTION_SCENE}
		else:
			return {"path": POINT_BAG_SCENE, "exp_gain": 50}
	else:
		if roll < 0.9:
			return {"path": RED_POTION_SCENE}
		else:
			return {"path": POINT_BAG_SCENE, "exp_gain": 200}

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
	amount = amount * XP_MULT
	if _all_maxed():
		print("[PlayerManager] All stats maxed — granting extra life instead")
		extra_life.emit()
		return
	xp += amount
	print("[PlayerManager] XP gained: +", amount, " | Total XP: ", xp)
	xp_changed.emit(xp)
	_check_thresholds()

func apply_level_up(track: String) -> void:
	if levels[track] >= 8:
		print("[PlayerManager] apply_level_up('" + track + "') ignored — already at max level")
		return
	if not can_level_up(track):
		print("[PlayerManager] apply_level_up('" + track + "') ignored — not enough XP (have ", xp, ", need ", xp_to_next(track), ")")
		return
	var old_level = levels[track]
	var cost := xp_to_next(track)
	xp -= cost
	levels[track] += 1
	pending_levelups -= 1
	pending_tracks.erase(track)
	print("[PlayerManager] Level up applied! ", track, ": ", old_level, " -> ", levels[track], " | XP spent: ", cost, " | XP remaining: ", xp, " | Pending level-ups remaining: ", pending_levelups)
	xp_changed.emit(xp)
	_invalidate_unaffordable_pending()

## Called by the UI cancel button. Stamps a reachable deferred_threshold if all tracks are pending.
func defer_level_up() -> void:
	var all_pending := true
	for track in levels:
		if not pending_tracks.has(track):
			all_pending = false
			break
	if all_pending:
		deferred_threshold = xp + 100
		print("[PlayerManager] Level-up deferred — next bar target set to: ", deferred_threshold)

## Returns true if current XP meets the threshold for the next level of [track].
func can_level_up(track: String) -> bool:
	var lv: int = levels[track]
	if lv >= 8:
		return false
	return xp >= THRESHOLDS[track][lv - 1]


func reset() -> void:
	xp = 0
	levels = { "life": 1, "magic": 1, "attack": 1 }
	pending_levelups = 0
	pending_tracks.clear()
	deferred_threshold = 0
	enemy_kill_count = 0
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
	print("[PlayerManager] Player died — resetting XP and pending level-ups")
	xp = 0
	pending_levelups = 0
	pending_tracks.clear()
	deferred_threshold = 0
	enemy_kill_count = 0
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

## Returns the XP threshold required to reach the next level of [track].
func xp_to_next(track: String) -> int:
	var lv: int = levels[track]
	if lv >= 8:
		return 0
	return THRESHOLDS[track][lv - 1]

## Returns the lowest XP threshold among tracks not yet pending.
## If all tracks are pending (fully deferred), returns a stable deferred_threshold target.
var next_threshold: int:
	get:
		var values: Array[int] = []
		for track in levels:
			if pending_tracks.has(track):
				continue
			var t := xp_to_next(track)
			if t > 0:
				values.append(t)
		if values.size() > 0:
			return values.min()
		return deferred_threshold


func _invalidate_unaffordable_pending() -> void:
	for i in range(pending_tracks.size() - 1, -1, -1):
		var t: String = pending_tracks[i]
		if not can_level_up(t):
			print("[PlayerManager] Pending level-up for '", t, "' invalidated — no longer affordable after XP spend")
			pending_tracks.remove_at(i)
			pending_levelups -= 1

func _check_thresholds() -> void:
	for track in levels:
		if can_level_up(track) and not pending_tracks.has(track):
			print("[PlayerManager] Threshold crossed for '", track, "'! Current level: ", levels[track], " | XP: ", xp, " >= ", xp_to_next(track), " — emitting level_up_available")
			pending_tracks.append(track)
			pending_levelups += 1
			level_up_available.emit()
			print("[PlayerManager] pending_levelups is now: ", pending_levelups, " | pending_tracks: ", pending_tracks)
	if deferred_threshold > 0 and xp >= deferred_threshold and pending_tracks.size() > 0:
		print("[PlayerManager] Deferred threshold reached (", deferred_threshold, ") — re-emitting level_up_available for pending tracks: ", pending_tracks)
		deferred_threshold = 0
		level_up_available.emit()

func _all_maxed() -> bool:
	for track in levels:
		if levels[track] < 8:
			return false
	return true
