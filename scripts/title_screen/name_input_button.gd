extends Button

func _on_button_down() -> void:
	Signals.name_input_button_pressed.emit(text)
