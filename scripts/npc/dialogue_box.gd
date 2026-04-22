class_name DialogueBox extends CanvasLayer

@onready var label: Label = $Panel/Label

var _caller: NPCInteractArea = null

func _ready() -> void:
	hide()

func show_dialogue(text: String, caller: NPCInteractArea) -> void:
	get_tree().get_first_node_in_group("sidescroll-player").process_mode = Node.PROCESS_MODE_DISABLED
	_caller = caller
	_caller.set_talking(true)
	label.text = text
	show()

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_accept"):
		get_tree().get_first_node_in_group("sidescroll-player").process_mode = Node.PROCESS_MODE_ALWAYS
		_dismiss()

func _dismiss() -> void:
	hide()
	if _caller:
		_caller.set_talking(false)
		_caller = null
