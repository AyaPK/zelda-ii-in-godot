class_name RedPotion extends Pickup

func collect() -> void:
	PlayerManager.current_hp = PlayerManager.max_hp
	kill()
