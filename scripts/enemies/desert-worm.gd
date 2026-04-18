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
@onready var hitbox: Area2D = $Hitbox
@onready var head_hurtbox: Area2D = $HeadHurtbox
@onready var body_hurtbox: Area2D = $BodyHurtbox

func _ready() -> void:
	super._ready()
	floor_y = global_position.y
	_apply_extension(0.0)
	_enter_state(State.HIDDEN)

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
	head_hurtbox.position.y = -amount

func _set_hitboxes_active(active: bool) -> void:
	hitbox.monitoring = active
	hitbox.monitorable = active
	body_hurtbox.monitoring = active
	body_hurtbox.monitorable = active
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
	var player := area.get_parent() as LinkSidescroll
	if player:
		hit_player(player)

func _on_body_hurtbox_area_entered(area: Area2D) -> void:
	var enemy := area.get_parent() as LinkSidescroll
	if enemy:
		force_retract()

func _on_head_hurtbox_area_entered(area: Area2D) -> void:
	pass
