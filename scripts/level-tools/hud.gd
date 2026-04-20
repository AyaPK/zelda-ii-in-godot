extends CanvasLayer
class_name Hud

var lifeslot := preload("res://scenes/level-tools/life_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenemanager.hud = self
	PlayerManager.xp_changed.connect(set_up_exp_bar)
	PlayerManager.level_up_available.connect(show_level_up_dialog)
	refresh_hud()
	$LevelUpPanel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_up_lifebar() -> void:
	for _c in $LifeBarNodes.get_children():
		if _c is LifeSlotTexture:
			_c.queue_free()
			await _c.tree_exited
	$LifeBar.max_value = PlayerManager.max_hp
	$LifeBar.size.x = int(PlayerManager.max_hp/2.0)
	$LifeBar.value = PlayerManager.current_hp
	for __ in int(PlayerManager.max_hp/16.0):
		var l: LifeSlotTexture = lifeslot.instantiate()
		if $LifeBarNodes.get_child_count() <= PlayerManager.max_hp/16.0:
			$LifeBarNodes.add_child(l)

func set_up_exp_bar(_amt: int) -> void:
	$Labels/CurrentXP.text = int_to_padded_string(PlayerManager.xp)
	$Labels/XPGoal.text = int_to_padded_string(PlayerManager.next_threshold)

func refresh_hud() -> void:
	$Labels/AtkLevel.text = str(PlayerManager.attack_level)
	$Labels/MagicLevel.text = str(PlayerManager.magic_level)
	$Labels/LifeLevel.text = str(PlayerManager.life_level)
	set_up_lifebar()
	set_up_exp_bar(0)

func int_to_padded_string(value: int) -> String:
	return "%04d" % value

func show_level_up_dialog() -> void:
	get_tree().paused = true
	$LevelUpPanel.show()
	$LevelUpPanel/Buttons/BC/Cancel.grab_focus()
	var levels_waiting: Array[String] = PlayerManager.pending_tracks
	
	if "attack" in levels_waiting:
		$LevelUpPanel/Buttons/BC/Attack.focus_mode = 2
	else:
		$LevelUpPanel/Buttons/BC/Attack.focus_mode = 0
	
	if "magic" in levels_waiting:
		$LevelUpPanel/Buttons/BC/Magic.focus_mode = 2
	else:
		$LevelUpPanel/Buttons/BC/Magic.focus_mode = 0
	
	if "life" in levels_waiting:
		$LevelUpPanel/Buttons/BC/Life.focus_mode = 2
	else:
		$LevelUpPanel/Buttons/BC/Life.focus_mode = 0
		
	$LevelUpPanel/Info/AtkAmt.text = str(PlayerManager.xp_to_next("attack"))
	$LevelUpPanel/Info/DefAmt.text = str(PlayerManager.xp_to_next("magic"))
	$LevelUpPanel/Info/LifAmt.text = str(PlayerManager.xp_to_next("life"))
	print(levels_waiting)

func _on_cancel_pressed() -> void:
	$LevelUpPanel.hide()
	get_tree().paused = false
	PlayerManager.defer_level_up()
	set_up_exp_bar(0)


func _on_attack_pressed() -> void:
	_apply_and_continue("attack")

func _on_magic_pressed() -> void:
	_apply_and_continue("magic")

func _on_life_pressed() -> void:
	_apply_and_continue("life")

func _apply_and_continue(track: String) -> void:
	PlayerManager.apply_level_up(track)
	refresh_hud()
	if PlayerManager.pending_levelups > 0:
		show_level_up_dialog()
	else:
		$LevelUpPanel.hide()
		get_tree().paused = false
