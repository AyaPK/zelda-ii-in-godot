extends Node2D

var selected_slot: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.stop_music()
	Signals.name_input_button_pressed.connect(name_input_button_pressed)
	show_main_screen()
	load_saves()
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if %MainMenuContainer.visible:
			print("aaa")
		else:
			%NamePreviewLabel.text = remove_last_letter(%NamePreviewLabel.text)

func _on_player_button_1_pressed() -> void:
	selected_slot = 1
	if SaveManager.slot_exists(1):
		%SelectedContainer.show()
		$MainMenuContainer/VBoxContainer/SelectedContainer/StartButton.grab_focus()
	else:
		show_name_entry()

func _on_player_button_2_pressed() -> void:
	selected_slot = 2
	if SaveManager.slot_exists(2):
		%SelectedContainer.show()
		$MainMenuContainer/VBoxContainer/SelectedContainer/StartButton.grab_focus()
	else:
		show_name_entry()
		
func _on_player_button_3_pressed() -> void:
	selected_slot = 3
	if SaveManager.slot_exists(3):
		%SelectedContainer.show()
		$MainMenuContainer/VBoxContainer/SelectedContainer/StartButton.grab_focus()
	else:
		show_name_entry()

func name_input_button_pressed(_s: String) -> void:
	print(_s+" was pressed")
	if len(%NamePreviewLabel.text) < 9:
		%NamePreviewLabel.text += _s

func _on_cancel_button_pressed() -> void:
	pass # Replace with function body.

func _on_done_button_button_down() -> void:
	if len(%NamePreviewLabel.text) > 0:
		SaveManager.new_game(selected_slot, %NamePreviewLabel.text)
		show_main_screen()

func remove_last_letter(text: String) -> String:
	if text.length() == 0:
		return text
	return text.substr(0, text.length() - 1)

func load_saves() -> void:
	$MainMenuContainer/VBoxContainer/PlayerSlot1/Label2.text = ""
	$MainMenuContainer/VBoxContainer/PlayerSlot2/Label2.text = ""
	$MainMenuContainer/VBoxContainer/PlayerSlot3/Label2.text = ""
	if SaveManager.slot_exists(1):
		$MainMenuContainer/VBoxContainer/PlayerSlot1/Label2.text = SaveManager.get_slot_info(1)["name"]
	if SaveManager.slot_exists(2):
		$MainMenuContainer/VBoxContainer/PlayerSlot2/Label2.text = SaveManager.get_slot_info(2)["name"]
	if SaveManager.slot_exists(3):
		$MainMenuContainer/VBoxContainer/PlayerSlot3/Label2.text = SaveManager.get_slot_info(3)["name"]

func show_main_screen() -> void:
	load_saves()
	%MainMenuContainer.show()
	%NameEntryContainer.hide()
	%PlayerButton1.grab_focus()
	%NameEntryContainer.hide()
	%NamePreview.hide()
	$CreateSave.hide()
	$Select.show()
	%SelectedContainer.hide()

func show_name_entry() -> void:
	$Select.hide()
	%NamePreview.show()
	$CreateSave.show()
	%MainMenuContainer.hide()
	%NameEntryContainer.show()
	%AbuttonText.grab_focus()
	%NamePreviewLabel.text = ""

func _on_delete_button_pressed() -> void:
	SaveManager.delete_slot(selected_slot)
	show_main_screen()

func _on_start_button_pressed() -> void:
	SaveManager.load_slot(selected_slot)
