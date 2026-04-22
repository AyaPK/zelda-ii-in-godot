class_name NPCInteractArea extends Interactable

var is_talking: bool = false

func activate() -> void:
	var dialogue_box := get_tree().get_first_node_in_group("dialogue-box") as DialogueBox
	if dialogue_box and not is_talking:
		print("b")
		var npc := get_parent() as NPC
		dialogue_box.show_dialogue(npc.dialogue, self)
		print("c")

func set_talking(value: bool) -> void:
	is_talking = value
	var player := get_tree().get_first_node_in_group("sidescroll-player") as LinkSidescroll
	if player:
		player.set_process(not value)

func _on_body_entered(body: Node2D) -> void:
	if body is LinkSidescroll:
		body.interactable = self

func _on_body_exited(body: Node2D) -> void:
	if body is LinkSidescroll:
		body.interactable = null
