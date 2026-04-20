extends CanvasLayer
class_name Hud

var lifeslot := preload("res://scenes/level-tools/life_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenemanager.hud = self
	PlayerManager.xp_changed.connect(set_up_exp_bar)
	refresh_hud()

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
