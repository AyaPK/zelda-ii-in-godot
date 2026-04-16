class_name MoblinSpear extends EnemyProjectile

const SPEAR_SPEED: float = 100.0
const SPEAR_GRAVITY: float = 300.0
const DESPAWN_TIME: float = 2.0

const GRAVITY_DELAY: float = 0.2

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
var gravity_timer: float = GRAVITY_DELAY

func _ready() -> void:
	velocity = direction * SPEAR_SPEED
	$Sprite2D.flip_h = direction.x > 0.0

	var timer := Timer.new()
	timer.wait_time = DESPAWN_TIME
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _process(delta: float) -> void:
	gravity_timer -= delta
	if gravity_timer <= 0.0:
		velocity.y += SPEAR_GRAVITY * delta
	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	var player := area.get_parent() as LinkSidescroll
	if player:
		var strength_idx: int = STRENGTHS.find(attack)
		if strength_idx == -1:
			strength_idx = 0
			for i in range(STRENGTHS.size() - 1, -1, -1):
				if attack >= STRENGTHS[i]:
					strength_idx = i
					break
		var life_idx: int = clampi(PlayerManager.levels["life"] - 1, 0, 7)
		var damage: int = DAMAGE_TABLE[strength_idx][life_idx]
		hit_player(player)
		queue_free()
