extends CanvasLayer
class_name Hud

var lifeslot := preload("res://scenes/level-tools/life_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenemanager.hud = self
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
		$LifeBarNodes.add_child(l)

func refresh_hud() -> void:
	$AtkLevel.text = str(PlayerManager.attack_level)
	$MagicLevel.text = str(PlayerManager.magic_level)
	$LifeLevel.text = str(PlayerManager.life_level)
	set_up_lifebar()
