extends CharacterBody2D

# NODES
@onready var camera: Camera2D = $Camera2D
@onready var wall_detector_left: RayCast2D = $WallDetectorLeft
@onready var wall_detector_right: RayCast2D = $WallDetectorRight
@onready var general_collision: CollisionShape2D = $GeneralCollision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var jump_sound_player: AudioStreamPlayer = $Sounds/JumpSoundPlayer
@onready var running_sound_player: AudioStreamPlayer = $Sounds/RunningSoundPlayer
@onready var sliding_sound_player: AudioStreamPlayer = $Sounds/SlidingSoundPlayer
@onready var landing_sound_player: AudioStreamPlayer = $Sounds/LandingSoundPlayer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var death_cooldown: Timer = $DeathCooldown

# CONSTANTS
const JUMP_VELOCITY = -350.0
const WALL_JUMP_VELOCITY = -300.0
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_FRICTION = 2000.0
const WALL_JUMP_PUSHBACK = 100.0
const WALL_JUMP_FRAMES = 10
const SPRINT_MULTIPLIER = 5.0
const SPRINT_TWEEN_SPEED = 2.0

# VARIABLES	
var speed= 200.0
var in_sprintzone= false
var wall_jump_frames = 0
var is_wall_sliding = false
var jump_zone_animation: String = ""
var was_on_floor: bool = false
var is_death: bool = false


# GENERAL PHYSICS
func _physics_process(delta: float) -> void:
	if is_death:
		return
		
	# GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta

	handle_wall_slide(delta)

	# LANDING
	if is_on_floor() and not was_on_floor:
		landing_sound_player.play()
		animated_sprite.play("landing")
	was_on_floor = is_on_floor()
	
	# JUMPS
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound_player.play()
			
		# IDLE JUMP
		if Input.get_axis("move_back", "move_front") == 0:
			animated_sprite.play("idle_jump")
		else:
			animated_sprite.play("jump_1")
	# FALLING
	if not is_on_floor() and not is_wall_sliding and velocity.y > 0:
		animated_sprite.play("falling")

	# Movement: Get the input direction: -1, 0, 1
	var direction :int = clamp(Input.get_axis("move_back", "move_front"), -1, 1)
	delta = clamp(delta, 0.0, 0.1) # Prevent extreme delta spikes

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

	# IDLE/RUN ANIMATION & SOUND
	if is_on_floor() and not is_wall_sliding:
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
	var target_speed: float = 200.0
	if wall_jump_frames == 0:
		if in_sprintzone and is_on_floor():
			target_speed = 1000.0
			velocity.x = move_toward(velocity.x, target_speed, abs(target_speed - 200) * delta)
		else:
			if direction != 0:
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

	# WALL MECHANICS
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
		
		if on_left_wall:
			velocity.x = WALL_JUMP_PUSHBACK
			animated_sprite.flip_h = false
		elif on_right_wall:
			velocity.x = -WALL_JUMP_PUSHBACK
			animated_sprite.flip_h = true
			
		animated_sprite.play("wall_jump")
		is_wall_sliding =false
		wall_jump_frames = WALL_JUMP_FRAMES
		wall_jump_timer.start()
		jump_sound_player.play()


# AREA2D SIGNALS - ENTRY
func _on_zones_entered(area: Area2D) -> void:
	if area and area.has_meta("sprintzone"):
		velocity.x = move_toward(velocity.x, speed * SPRINT_MULTIPLIER, SPRINT_TWEEN_SPEED)
		camera.call("start_shake")
		camera.call("set_zoom_factor", 0.5)
		in_sprintzone = true
		
	# Add multiple jump animations
	if area and area.has_meta("jump_1"):
		jump_zone_animation = "jump_1"
	elif area and area.has_meta("jump_2"):
		jump_zone_animation = "jump_2"
	elif area and area.has_meta("jump_3"):
		jump_zone_animation = "jump_3"


# AREA2D SIGNALS - EXIT
func _on_zones_exited(area: Area2D) -> void:
	#Rest speed when leaving zone
	if area and area.has_meta("sprintzone"):
		speed = 200.0
		in_sprintzone = false
		camera.call("start_shake")
		camera.reset_zoom()

	# Reset to default jump animation when leaving zone
	if area and area.has_meta("jump_1") or area.has_meta("jump_2") or area.has_meta("jump_3"):
		jump_zone_animation = ""


# DEATH
func _on_lethal_entered(area: Area2D) -> void:
	if area and area.has_meta("lethal") and not is_death:
		is_death = true
		Engine.time_scale = 0.3
		velocity = Vector2.ZERO
		animated_sprite.play("death")
		death_cooldown.start()


# RESTART LEVEL
func _on_death_cooldown_timeout() -> void:
	Engine.time_scale = 1.0
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)
