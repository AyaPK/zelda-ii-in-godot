class_name EnemyProjectile extends Area2D

@export var attack: int = 8

const STRENGTHS: Array[int] = [8, 16, 24, 48, 72, 112]
const DAMAGE_TABLE: Array = [
	[8,  6,  6,  6,  4,  4,  2,  2],
	[16, 14, 10,  8,  6,  6,  4,  4],
	[24, 20, 18, 16, 12, 10,  8,  6],
	[48, 36, 28, 24, 20, 16, 14, 12],
	[72, 60, 48, 36, 28, 24, 20, 16],
	[112, 80, 64, 56, 48, 40, 32, 24],
]

func hit_player(player: LinkSidescroll) -> void:
	var strength_idx: int = STRENGTHS.find(attack)
	if strength_idx == -1:
		strength_idx = 0
		for i in range(STRENGTHS.size() - 1, -1, -1):
			if attack >= STRENGTHS[i]:
				strength_idx = i
				break
	var life_idx: int = clampi(PlayerManager.levels["life"] - 1, 0, 7)
	var damage: int = DAMAGE_TABLE[strength_idx][life_idx]
	print(damage)
	player.hit(global_position.x, damage)
	if Scenemanager.hud:
		Scenemanager.hud.refresh_hud()
