class_name LevelToLevel extends Area2D

@export_file("*.tscn") var target_scene: String
@export var node_name: String
@export_enum("Left", "Right") var facing_direction = "Left"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is LinkSidescroll:
		Scenemanager.call_deferred("change_scene_to_level", target_scene, node_name, facing_direction)
