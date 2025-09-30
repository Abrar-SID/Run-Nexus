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
@onready var roll_collision: CollisionShape2D = $RollCollision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var jump_sound_player: AudioStreamPlayer = $JumpSoundPlayer
@onready var running_sound_player: AudioStreamPlayer = $RunningSoundPlayer
@onready var sliding_sound_player: AudioStreamPlayer = $SlidingSoundPlayer
@onready var rolling_sound_player: AudioStreamPlayer = $RollingSoundPlayer
@onready var landing_sound_player: AudioStreamPlayer = $LandingSoundPlayer
@onready var wall_jump_timer: Timer = $WallJumpTimer


#CONSTANTS
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = -300.0
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_FRICTION = 2000.0
const WALL_JUMP_LOCK_FRAMES = 10
const WALL_JUMP_COOLDOWN = 0.25

#VARIABLES
var speed= 200.0
var current_jump_animation = "idle_jump"
var in_sprintzone= false
var wall_jump_frames = 0
var is_wall_sliding = false
var jump_zone_animation: String = ""
var wall_jump_press_count = 0
var is_rolling: bool = false
var was_on_floor: bool = false
var last_wall_jump_time: float = -1.0


# GENERAL PHYSICS
func _physics_process(delta: float) -> void:
	# Adding gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite.play(current_jump_animation)


	handle_wall_slide(delta)

	if is_on_floor() and not was_on_floor:
		landing_sound_player.play()
	was_on_floor = is_on_floor()
	
	# Handling jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if not in_sprintzone:
			velocity.y = JUMP_VELOCITY
			jump_sound_player.play()
			
			# Idle jump handling
			if velocity.x == 0:
				animated_sprite.play("idle_jump")
			elif jump_zone_animation != "":
				current_jump_animation = jump_zone_animation
			else:
				animated_sprite.play("jump_1")
		else:
			current_jump_animation = "falling"
		animated_sprite.play(current_jump_animation)
	
	if not is_on_floor() and not is_wall_sliding:
		if velocity.y > 0:
			animated_sprite.play("falling")

	# Handling roll
	if Input.is_action_just_pressed("roll") and not is_rolling and is_on_floor():
		is_rolling = true
		general_collision.disabled = true
		roll_collision.disabled = false
		animated_sprite.play("roll")
		rolling_sound_player.play()


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
		if not is_wall_sliding:
			if direction == 0:
				animated_sprite.play("idle")
				if running_sound_player.playing:
					running_sound_player.stop()
			else:
				animated_sprite.play("run")
				if not running_sound_player.playing:
					running_sound_player.play()
	else:
		if running_sound_player.playing:
			running_sound_player.stop()
				

	# Velocity changes
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
	var was_sliding = is_wall_sliding
	is_wall_sliding = false

	if is_on_floor() or wall_jump_frames > 0:
		if was_sliding and sliding_sound_player:
			sliding_sound_player.stop()
		return


	var on_left = wall_detector_left.is_colliding()
	var on_right = wall_detector_right.is_colliding()
	var pressing_left = Input.is_action_pressed("move_back")
	var pressing_right = Input.is_action_pressed("move_front")


	# Add stick to the wall mechanics
	if (on_left or on_right) and velocity.y >= 0.0:
		is_wall_sliding = true
		animated_sprite.play("wall_sliding")
		
		if not was_sliding and not sliding_sound_player.playing:
			sliding_sound_player.play()
		
		if ((on_left and pressing_left) or (on_right and pressing_right)):
			velocity.y = move_toward(velocity.y, 0.0, WALL_SLIDE_FRICTION * delta)
		else:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_FRICTION * delta)
	else:
		if was_sliding and sliding_sound_player.playing:
			sliding_sound_player.stop()




# WALL JUMPS
func handle_walljump() -> void:

	if is_on_floor() or in_sprintzone:
		return


	var on_left_wall = wall_detector_left.is_colliding()
	var on_right_wall = wall_detector_right.is_colliding()


	# Add jump press counting system
	if Input.is_action_just_pressed("jump") and (on_left_wall or on_right_wall) and not wall_jump_timer.is_stopped():
		return
	if Input.is_action_just_pressed("jump") and (on_left_wall or on_right_wall):
			velocity.y = WALL_JUMP_VELOCITY
			animated_sprite.play("wall_jump")
			is_wall_sliding =false
			wall_jump_timer.start()



# AREA2D SIGNALS - ENTRY
func _on_zones_entered(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		speed = 1000.0
		camera.call("start_shake")
		in_sprintzone = true


	# Add multiple jump animations
	if area.has_meta("jump_1"):
		jump_zone_animation = "jump_1"

	elif area.has_meta("jump_2"):
		jump_zone_animation = "jump_2"

	elif area.has_meta("jump_3"):
		jump_zone_animation = "jump_3"



# AREA2D SIGNALS - EXIT
func _on_zones_exited(area: Area2D) -> void:
	#Rest speed when leaving zone
	if area.has_meta("sprintzone"):
		speed = 200.0
		in_sprintzone = false
		camera.call("start_shake")

	# Reset to default jump animation when leaving zone
	if area.has_meta("jump_1") or area.has_meta("jump_2") or area.has_meta("jump_3"):
		jump_zone_animation = ""


# DEATH
func _on_lethal_entered(area: Area2D) -> void:
	
	if area.has_meta("lethal"):
		call_deferred("_reload_scene")



# RESTART
func _reload_scene() -> void:
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)


# CHECKING ANIMATION CHANGES
func _on_animated_sprite_animation_finished() -> void:
	if animated_sprite.animation == "roll":
		is_rolling = false
		general_collision.disabled = false
		roll_collision.disabled = true
