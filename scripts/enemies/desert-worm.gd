class_name DesertWorm extends EncounterEnemy

enum State { HIDDEN, EMERGE, EXTENDED, RETRACT }

@export var hide_duration: float = 2.0
@export var extended_duration: float = 20
@export var emerge_speed: float = 60.0
@export var retract_speed: float = 80.0
@export var extend_height: float = 64.0

var state: State = State.HIDDEN
var state_timer: float = 0.0
var floor_y: float = 0.0
var current_extension: float = 0.0

@onready var body_segments: Array[Sprite2D] = [
	$BodySprite1, $BodySprite2, $BodySprite3, $BodySprite4
]
@onready var head_sprite: Sprite2D = $HeadSprite
@onready var head_hurtbox: Area2D = $HeadHurtbox
@onready var body_hurtbox_1: Area2D = $BodyHurtbox1
@onready var body_hurtbox_2: Area2D = $BodyHurtbox2
@onready var body_hurtbox_3: Area2D = $BodyHurtbox3
@onready var body_hurtbox_4: Area2D = $BodyHurtbox4
@onready var hitbox_2: Area2D = $BodySprite1/Hitbox2
@onready var hitbox_3: Area2D = $BodySprite2/Hitbox3
@onready var hitbox_4: Area2D = $BodySprite3/Hitbox4
@onready var hitbox_5: Area2D = $BodySprite4/Hitbox5




func _ready() -> void:
	super._ready()
	z_index = -1
	floor_y = global_position.y
	_apply_extension(0.0)
	_enter_state(State.HIDDEN)
	
func _process(delta: float) -> void:
	if iframe_timer > 0.0:
		iframe_timer -= delta
		flash_timer -= delta
		if flash_timer <= 0.0:
			flash_timer = flash_interval
			$BodySprite1.modulate = flash_color if $BodySprite1.modulate == Color.WHITE else Color.WHITE
			$BodySprite2.modulate = flash_color if $BodySprite1.modulate == Color.WHITE else Color.WHITE
			$BodySprite3.modulate = flash_color if $BodySprite1.modulate == Color.WHITE else Color.WHITE
			$BodySprite4.modulate = flash_color if $BodySprite1.modulate == Color.WHITE else Color.WHITE
			$HeadSprite.modulate = flash_color if $HeadSprite.modulate == Color.WHITE else Color.WHITE
	else:
		$BodySprite1.modulate = Color.WHITE
		$BodySprite2.modulate = Color.WHITE
		$BodySprite3.modulate = Color.WHITE
		$BodySprite4.modulate = Color.WHITE
		$HeadSprite.modulate = Color.WHITE

	if is_stunned:
		hit_stun_timer -= delta
		if hit_stun_timer <= 0.0:
			is_stunned = false

func _physics_process(delta: float) -> void:
	match state:
		State.HIDDEN:
			state_timer -= delta
			if state_timer <= 0.0:
				_enter_state(State.EMERGE)

		State.EMERGE:
			current_extension = move_toward(current_extension, extend_height, emerge_speed * delta)
			_apply_extension(current_extension)
			if current_extension >= extend_height:
				_enter_state(State.EXTENDED)

		State.EXTENDED:
			state_timer -= delta
			if state_timer <= 0.0:
				_enter_state(State.RETRACT)

		State.RETRACT:
			current_extension = move_toward(current_extension, 0.0, retract_speed * delta)
			_apply_extension(current_extension)
			if current_extension <= 0.0:
				_enter_state(State.HIDDEN)

func _apply_extension(amount: float) -> void:
	var segment_count: int = body_segments.size()
	var segment_step: float = extend_height / segment_count
	body_segments[0].visible = amount > 0.0
	body_segments[0].position.y = 0.0
	for i in range(1, segment_count):
		var threshold: float = segment_step * i
		var seg: Sprite2D = body_segments[i]
		seg.visible = amount >= threshold
		seg.position.y = -threshold
	head_sprite.position.y = -amount
	$BodyHurtbox1.global_position = $BodySprite1.global_position
	$BodyHurtbox2.global_position = $BodySprite2.global_position
	$BodyHurtbox3.global_position = $BodySprite3.global_position
	$BodyHurtbox4.global_position = $BodySprite4.global_position

func _set_hitboxes_active(active: bool) -> void:
	body_hurtbox_1.monitoring = active
	body_hurtbox_1.monitorable = active
	body_hurtbox_2.monitoring = active
	body_hurtbox_2.monitorable = active
	body_hurtbox_3.monitoring = active
	body_hurtbox_3.monitorable = active
	body_hurtbox_4.monitoring = active
	body_hurtbox_4.monitorable = active
	hitbox_2.monitoring = $BodySprite1.visible
	hitbox_2.monitorable = $BodySprite1.visible
	hitbox_3.monitoring = $BodySprite2.visible
	hitbox_3.monitorable = $BodySprite2.visible
	hitbox_4.monitoring = $BodySprite3.visible
	hitbox_4.monitorable = $BodySprite3.visible
	hitbox_5.monitoring = $BodySprite4.visible
	hitbox_5.monitorable = $BodySprite4.visible
	head_hurtbox.monitoring = true
	head_hurtbox.monitorable = true

func _enter_state(next: State) -> void:
	state = next
	match state:
		State.HIDDEN:
			state_timer = hide_duration
			_set_hitboxes_active(false)
		State.EMERGE:
			_set_hitboxes_active(true)
		State.EXTENDED:
			state_timer = extended_duration
		State.RETRACT:
			_set_hitboxes_active(false)

func force_retract() -> void:
	if state == State.EMERGE or state == State.EXTENDED:
		_enter_state(State.RETRACT)

func _on_hitbox_area_entered(area: Area2D) -> void:
	pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var player := area.get_parent() as LinkSidescroll
	if player:
		hit_player(player)
