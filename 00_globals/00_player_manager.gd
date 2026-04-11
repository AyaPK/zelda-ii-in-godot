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
var levels: Dictionary = { "life": 1, "magic": 1, "attack": 1 }
var pending_levelups: int = 0

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

func on_player_death() -> void:
	xp = 0
	pending_levelups = 0
	xp_changed.emit(xp)

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
