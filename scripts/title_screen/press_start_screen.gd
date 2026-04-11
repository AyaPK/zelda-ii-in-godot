extends Node2D

func _ready() -> void:
	AudioManager.play_music("title")

func _on_logo_start_scroll_timeout() -> void:
	$TitleAnim.play("scroll")


func _on_text_start_scroll_timeout() -> void:
	$StoryAnim.play("scroll_story")

func _on_story_anim_animation_finished(anim_name: StringName) -> void:
	$TextStartScroll.wait_time = 34
	$TitleAnim.play("scroll")
	$TextStartScroll.start()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file("res://scenes/title_screen/character_select.tscn")
