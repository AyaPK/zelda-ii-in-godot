class_name FlyingRock extends EncounterEnemy

@export var move_speed: float = 80.0
var direction: float = 1.0

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	velocity.x = direction * move_speed
	move_and_slide()
	_check_off_screen()

func _check_off_screen() -> void:
	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	if not player:
		return
	var cam := player.camera
	var half_w := get_viewport_rect().size.x / 2.0 / cam.zoom.x
	var cam_x := clampf(cam.global_position.x, cam.limit_left + half_w, cam.limit_right - half_w)
	if global_position.x < cam_x - half_w - 32.0 or global_position.x > cam_x + half_w + 32.0:
		deactivate()

func take_hit(_damage: int = 0) -> void:
	pass

func deactivate() -> void:
	hide()
	set_process_mode(PROCESS_MODE_DISABLED)
	for child in get_children():
		if child is CollisionShape2D or child is CollisionObject2D:
			child.set_deferred("disabled", true)

func activate(start_pos: Vector2, dir: float) -> void:
	direction = dir
	global_position = start_pos
	$Sprite2D.flip_h = direction < 0.0
	for child in get_children():
		if child is CollisionShape2D or child is CollisionObject2D:
			child.set_deferred("disabled", false)
	show()
	set_process_mode(PROCESS_MODE_INHERIT)

func blocked() -> void:
	AudioManager.play_sfx("deflect")
	deactivate()
