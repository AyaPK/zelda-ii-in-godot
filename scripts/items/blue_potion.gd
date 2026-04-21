class_name BluePotion extends Pickup

func collect() -> void:
	PlayerManager.magic = PlayerManager.max_magic
	kill()
