class_name LowderEnemy extends EncounterEnemy

@export var speed: float = 50.0
@export var walk_right: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	animation_player.play("walk")
	$Sprite2D.flip_h = walk_right

func _physics_process(delta: float) -> void:
	if is_stunned:
		velocity.x = 0.0
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = speed if walk_right else -speed
	move_and_slide()

	if is_on_wall():
		walk_right = !walk_right
		$Sprite2D.flip_h = walk_right

func _on_hitbox_area_entered(area: Area2D) -> void:
	var player := area.get_parent() as LinkSidescroll
	if player:
		hit_player(player)
