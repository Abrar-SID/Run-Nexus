extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

#Add const and var here
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

#Add the Movement: Jump, Run, Slide
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite.play("jump_2")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_back" , "move_front")
	
	#fliping sprite.
	if Input.is_action_pressed("move_back"):
		animated_sprite.flip_h = true
	if Input.is_action_pressed("move_front"):
		animated_sprite.flip_h = false
		
	#Action animations.
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

#The special sprint zone is coded here:
func _on_sprintzone_entered(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		velocity.x = SPEED * 4
	else:
		velocity.x = SPEED


func _on_lethal_entered(area: Area2D) -> void:
	if area.has_meta("lethal"):
		get_tree().reload_current_scene()


func _on_obstacle_entered_jump(area: Area2D) -> void:
	if area.has_meta("anijump_1"):
		animated_sprite.play("jump_1")
	if area.has_meta("anijump_2"):
		animated_sprite.play("jump_2")
	if area.has_meta("anijump_3"):
		animated_sprite.play("jump_3")
	
