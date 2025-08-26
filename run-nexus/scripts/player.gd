extends CharacterBody2D

@export var jump_sound: Node
@export var running_sound: Node

#NODES
@onready var camera: Camera2D = $Camera2D
@onready var head_dector_left: RayCast2D = $HeadDectorLeft
@onready var head_dector_right: RayCast2D = $HeadDectorRight
@onready var wall_detector_left: RayCast2D = $WallDetectorLeft
@onready var wall_detector_right: RayCast2D = $WallDetectorRight
@onready var general_collision: CollisionShape2D = $GeneralCollision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var jump_sound_player: AudioStreamPlayer = $JumpSoundPlayer
@onready var running_sound_player: AudioStreamPlayer = $RunningSoundPlayer




#CONSTANTS
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = -300.0
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_FRICTION = 2000.0
const WALL_JUMP_LOCK_FRAMES = 10

#VARIABLES
var speed= 200.0
var current_jump_animation = "falling"
var in_sprintzone= false
var wall_jump_frames = 0
var is_wall_sliding = false
var jump_zone_animation: String = ""
var wall_jump_press_count = 0
var is_rolling: bool = false


# GENERAL PHYSICS
func _physics_process(delta: float) -> void:

	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite.play(current_jump_animation)


	handle_wall_slide(delta)


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if Input.is_action_just_pressed("jump") and is_on_floor() and not in_sprintzone:
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			
			# Idle jump handling
			if velocity.x == 0:
				animated_sprite.play("idle_jump")
			elif jump_zone_animation != "":
				animated_sprite.play(jump_zone_animation)
			else:
				animated_sprite.play("jump_1")
				
	
	if not is_on_floor() and not Input.is_action_just_pressed("jump") and not is_wall_sliding:
		animated_sprite.play("falling")


	if Input.is_action_just_pressed("roll") and not is_rolling and is_on_floor():
		is_rolling = true
		general_collision.disabled = true
		animated_sprite.play("roll")

	# Movement: Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_back" , "move_front")


	if wall_jump_frames > 0:
		wall_jump_frames -= 1
	else: 
		if in_sprintzone and is_on_floor():
			direction = 1
			animated_sprite.flip_h = false
		else:
			if direction < 0:
				animated_sprite.flip_h = true
			elif direction > 0:
				animated_sprite.flip_h = false


	if is_on_floor():
		if is_on_floor() and not is_wall_sliding:
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
				running_sound.play()


	if wall_jump_frames == 0:
		if in_sprintzone and is_on_floor():
			velocity.x = speed
		else:
			if direction:
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)


	# Handle wall jump
	handle_walljump()

	# Handle player movement
	move_and_slide()



# WALL SLIDING
func handle_wall_slide(delta: float) -> void:
	is_wall_sliding = false

	if is_on_floor() or wall_jump_frames > 0:
		return


	var on_left = wall_detector_left.is_colliding()
	var on_right = wall_detector_right.is_colliding()
	
	var pressing_left = Input.is_action_pressed("move_back")
	var pressing_right = Input.is_action_pressed("move_front")


	# Add stick to the wall mechanics
	if (on_left or on_right) and velocity.y >= 0.0:
		is_wall_sliding = true
		animated_sprite.play("wall_climbing")
		
		
		if ((on_left and pressing_left) or (on_right and pressing_right)):
			velocity.y = move_toward(velocity.y, 0.0, WALL_SLIDE_FRICTION * delta)
		else:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_FRICTION * delta)
		




# WALL JUMPS
func handle_walljump() -> void:

	if is_on_floor() or in_sprintzone:
		wall_jump_press_count = 0
		return


	var on_left_wall = wall_detector_left.is_colliding()
	var on_right_wall = wall_detector_right.is_colliding()


	# Add jump press counting system
	if Input.is_action_just_pressed("jump") and (on_left_wall or on_right_wall):
		wall_jump_press_count += 1


		# Add double press wall jump mechanic
		if wall_jump_press_count >= 2:
			velocity.y = WALL_JUMP_VELOCITY
			animated_sprite.play("wall_climbing")
			wall_jump_press_count = 0
			return

		is_wall_sliding = false



# AREA2D SIGNALS - ENTRY
func _on_zones_entered(area: Area2D) -> void:

	if area.has_meta("sprintzone"):
		speed = 1000.0
		camera.call("start_shake")
		in_sprintzone = true


	# Add multiple jump animations
	if area.has_meta("jump1"):
		camera.call("start_shake")
		animated_sprite.play("jump_1")

	elif area.has_meta("jump2"):
		camera.call("start_shake")
		animated_sprite.play("jump_2")

	elif area.has_meta("jump3"):
		camera.call("start_shake")
		animated_sprite.play("jump_3")



# AREA2D SIGNALS - EXIT
func _on_zones_exited(area: Area2D) -> void:
	
	#Rest speed when leaving zone
	if area.has_meta("sprintzone"):
		speed = 200.0
		in_sprintzone = false
		camera.call("start_shake")


	# Reset to default jump animation when leaving zone
	if area.has_meta("jump_ani_1") or area.has_meta("jump_ani_2") or area.has_meta("jump_ani_3"):
		animated_sprite.play("jump_1")


# DEATH
func _on_lethal_entered(area: Area2D) -> void:
	
	if area.has_meta("lethal"):
		call_deferred("_reload_scene")



# RESTART
func _reload_scene() -> void:
	get_tree().reload_current_scene()


# CHECKING ANIMATION CHANGES
func _on_animated_sprite_animation_finished() -> void:
	if animated_sprite.animation == "roll":
		is_rolling = false
		general_collision.disabled = false
