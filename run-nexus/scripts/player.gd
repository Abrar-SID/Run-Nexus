extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var SPEED = 400.0
const JUMP_VELOCITY = -600.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_back" , "move_front")
	
	#fliping sprite.
	if Input.is_action_pressed("move_back"):
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
		
	#Action animations.
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

#The special sprint zone is coded here:
func _on_sprintzone_entered(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		SPEED = 1000.0
	else:
		SPEED = 400.0

#Under here, the codes for different jump animations is done:
func _on_obstacle_1_entered(area: Area2D) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and area.has_meta("obstacle_jump_2"):
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump_animation_01")
