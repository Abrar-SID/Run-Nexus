extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var leftray: RayCast2D = $raycastLeft
@onready var rightray: RayCast2D = $raycastRight


#Add const and var here
var SPEED = 200.0
const JUMP_VELOCITY = -400.0
const WALL_JUMP_PUSHBACK = -350.0
const WALL_SLIDE_SPEED = 10.0
const WALL_SLIDE_FRICTION = 500.0
const WALL_JUMP_LOCK_FRAMES = 10

var CURRENT_JUMP_ANIMATION = "falling"
var IN_SPRINTZONE= false
var WALL_JUMP_FRAMES = 0
var IS_WALL_SLIDING = false

#Add the Movement: Jump, Run, Slide
func _physics_process(delta: float) -> void:
		# Add the gravity.
	velocity += get_gravity() * delta
	
	handle_wall_slide(delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not IN_SPRINTZONE:
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = 0
	
	if WALL_JUMP_FRAMES > 0:
		WALL_JUMP_FRAMES -= 1
	else: 
		if IN_SPRINTZONE and is_on_floor():
			direction = 1
			animated_sprite.flip_h = false
		else:
			direction = Input.get_axis("move_back", "move_front")
			if direction < 0:
				animated_sprite.flip_h = true
			elif direction > 0:
				animated_sprite.flip_h = false

	
	#Action animations.
	if is_on_floor() and not IS_WALL_SLIDING:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif not is_on_floor() and not IS_WALL_SLIDING:
		animated_sprite.play(CURRENT_JUMP_ANIMATION)
	
	if WALL_JUMP_FRAMES == 0:
		if IN_SPRINTZONE and is_on_floor():
			velocity.x = SPEED
		else:
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#Handle wall jump here
	handle_walljump()
	
	#Finish by adding MOVE
	move_and_slide()
	

func handle_wall_slide(delta: float) -> void:
	IS_WALL_SLIDING = false
	if is_on_floor():
		return

	if WALL_JUMP_FRAMES > 0:
		return

	var ON_LEFT = leftray.is_colliding()
	var ON_RIGHT = rightray.is_colliding()
	
	var PRESSING_LEFT = Input.is_action_pressed("move_back")
	var PRESSING_RIGHT = Input.is_action_pressed("move_front")
	
	var SLIDE_LEFT = ON_LEFT and PRESSING_LEFT
	var SLIDE_RIGHT = ON_RIGHT and PRESSING_RIGHT
	
	if (SLIDE_LEFT or SLIDE_RIGHT) and velocity.y >= 0.0:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_FRICTION * delta)
		IS_WALL_SLIDING = true
		animated_sprite.play("wall_slide")

#Code wall jump here
func handle_walljump() -> void:
	if is_on_floor() or IN_SPRINTZONE:
		return
	
	if WALL_JUMP_FRAMES > 0:
		return
		
	var ON_LEFT_WALL = leftray.is_colliding()
	var ON_RIGHT_WALL = rightray.is_colliding()
	
	if Input.is_action_just_pressed("jump"):
		if ON_LEFT_WALL:
			velocity.x = SPEED
			velocity.y = WALL_JUMP_PUSHBACK
			animated_sprite.flip_h = false
			CURRENT_JUMP_ANIMATION = "jump_1"
			WALL_JUMP_FRAMES = WALL_JUMP_LOCK_FRAMES
		elif ON_RIGHT_WALL:
			velocity.x = -SPEED
			velocity.y = WALL_JUMP_PUSHBACK
			animated_sprite.flip_h = true
			CURRENT_JUMP_ANIMATION = "jump_1"
			WALL_JUMP_FRAMES  = WALL_JUMP_LOCK_FRAMES
			
		IS_WALL_SLIDING = false


#The special sprint zone is coded here:
func _on_sprintzone_entered(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		SPEED = 1000.0
		IN_SPRINTZONE = true
		
func _on_sprintzone_exited(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		SPEED = 200.0
		IN_SPRINTZONE = false

#Code death  here
func _on_lethal_entered(area: Area2D) -> void:
	if area.has_meta("lethal"):
		get_tree().reload_current_scene()


#Code multiple jump animations here
func _on_obstacle_entered_jump(area: Area2D) -> void:
	if area.has_meta("anijump_1"):
		CURRENT_JUMP_ANIMATION = "jump_1"
	if area.has_meta("anijump_2"):
		CURRENT_JUMP_ANIMATION = "jump_2"
	if area.has_meta("anijump_3"):
		CURRENT_JUMP_ANIMATION = "jump_3"
