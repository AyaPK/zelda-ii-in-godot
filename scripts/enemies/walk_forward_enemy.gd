class_name WalkForwardEnemy extends CharacterBody2D

const SPEED = 60.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity.x = -SPEED

	move_and_slide()
