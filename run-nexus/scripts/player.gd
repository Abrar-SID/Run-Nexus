extends CharacterBody2D

# =====================
# PLAYER CONTROLLER SCRIPT PURPOSE
# =====================
# Handling all player movment, wall sliding, wall jumping, sprint zones.
# Handling death, and related sounds and animations.
# Designed for modularity and physcis consistency across all levels.

# ===================
# NODES REFERENCES
# ===================
# Links to essential nodes like camera, detectors, animations, sounds and timers.
@onready var camera: Camera2D = $Camera2D
@onready var wall_detector_left: RayCast2D = $WallDetectorLeft
@onready var wall_detector_right: RayCast2D = $WallDetectorRight
@onready var general_collision: CollisionShape2D = $GeneralCollision
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var death_cooldown: Timer = $DeathCooldown

# ==================
# CONSTANTS
# ==================
# Tunable values for jump strength, wall mechanics, sprinting, and timing.
const JUMP_VELOCITY = -350.0
const WALL_JUMP_VELOCITY = -300.0
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_FRICTION = 2000.0
const WALL_JUMP_PUSHBACK = 150.0
const WALL_JUMP_FRAMES = 10
const SPRINT_MULTIPLIER = 5.0
const SPRINT_ACCELERATION = 2.0
const SPRINT_DECELERATION = 800.0
const JUMP_BUFFER_MAX = 5

@export var running_sound_player : Node
@export var sliding_sound_player : AudioStreamPlayer
@export var jump_sound_player: Node

# ================
# VARIABLES	
# ================
# State tracking for speed, wall and death conditions.
var speed: float = 200.0
var sprint_target_speed: float = 1000.0
var in_sprint_zone: bool = false
var wall_jump_frames = 0
var is_wall_sliding: bool = false
var is_death: bool = false
var is_jumping: bool = false


# ========================
# MAIN PHYSICS PROCESS 
# ========================
# Handles movement, jumping, animations and gravity each frame.
func _physics_process(delta: float) -> void:
	if is_death:
		return
	
	# Decrement wall jump frames.
	if wall_jump_frames > 0:
		wall_jump_frames -= 1
	
	apply_gravity(delta)
	handle_wall_slide(delta)
	handle_movement(delta)
	handle_walljump()
	move_and_slide()


# Applies gravity gradually over time isntead of instantly.
# Keeps jump arcs consistent regardless of frame rate.
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func handle_movement(delta: float) -> void:
	# Movement Input. Getting the input direction: -1, 0, 1.
	var direction :int = clamp(Input.get_axis("move_back", "move_front"), -1, 1)
	delta = clamp(delta, 0.0, 0.1) # Prevent extreme delta spikes.
	
	# Lock player in sprint zone.
	if in_sprint_zone and is_on_floor() and wall_jump_frames == 0:
		velocity.x = move_toward(
			velocity.x, 
			sprint_target_speed, 
			abs(sprint_target_speed - speed) * delta
		)
		direction = 1
		animated_sprite.flip_h = false
		is_jumping = false # blocks jumping
		animated_sprite.play("run")
		return
		
	
	#Normal movement here.
	# Idle/Run state logic and sound control and Handle jump logic (floor and wall).
	if not is_wall_sliding:
		if is_on_floor():
			is_jumping = false
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				is_jumping = true
				if direction == 0:
					animated_sprite.play("idle_jump")
				else:
					animated_sprite.play("normal_jump")
				stop_running_sound()
			else:
				if direction == 0:
					animated_sprite.play("idle")
					stop_running_sound()
				else:
					animated_sprite.play("run")
					start_running_sound()
		else:
			if not is_jumping:
				animated_sprite.play("falling")
				stop_running_sound()
	
	# Handling sprite flipping depending on direction of the player.
	if wall_jump_frames == 0:
		if direction < 0:
			animated_sprite.flip_h = true
		elif direction > 0:
			animated_sprite.flip_h = false
	
	# Adjusting horizontal velocity.
	if wall_jump_frames == 0:
		if direction != 0:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)


# To check when normal jump ends so that falling can start.
func _on_animated_sprite_animation_finished() -> void:
	if animated_sprite.animation in ["normal_jump", "idle_jump"]:
		is_jumping = false
		if not is_on_floor() and not is_wall_sliding:
			animated_sprite.play("falling")


# =================
# WALL SLIDING
# =================
# Handle wall slide, detection, friction and sound.
func handle_wall_slide(delta: float) -> void:
	if in_sprint_zone and is_on_floor():
		stop_sliding_sound()
		is_wall_sliding = false
		return
		
	var was_sliding = is_wall_sliding
	is_wall_sliding = false
	
	if is_on_floor() or wall_jump_frames > 0:
		if was_sliding:
			stop_sliding_sound()
		return
	
	var on_left = wall_detector_left.is_colliding()
	var on_right = wall_detector_right.is_colliding()
	var pressing_left = Input.is_action_pressed("move_back")
	var pressing_right = Input.is_action_pressed("move_front")
	
	if (on_left or on_right) and velocity.y >= 0.0:
		is_wall_sliding = true
		animated_sprite.play("wall_sliding")
		start_sliding_sound()
		
		if ((on_left and pressing_left) or (on_right and pressing_right)):
			velocity.y = move_toward(
				velocity.y, 
				0.0, 
				WALL_SLIDE_FRICTION * delta
				)
		else:
			velocity.y = move_toward(
				velocity.y, 
				WALL_SLIDE_SPEED, 
				WALL_SLIDE_FRICTION * delta
				)
	else:
		stop_sliding_sound()


# ============
# WALL JUMPS
# ============
# Enables jumping off walls and pushback and animations.
func handle_walljump() -> void:
	if is_on_floor() or in_sprint_zone:
		return
	
	var on_left_wall = wall_detector_left.is_colliding()
	var on_right_wall = wall_detector_right.is_colliding()
	
	if Input.is_action_just_pressed("jump") \
		and (on_left_wall or on_right_wall) \
		and not wall_jump_timer.is_stopped():
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


# ==============================
# AREA2D/ZONE SIGNALS
# ==============================
# Sprintzone and lethal adjust movement and animations dynamically.
func _on_zones_entered(area: Area2D) -> void:
	if area and area.has_meta("sprintzone"):
		# Gradually restores player speed after leaving speint zone.
		# Aceleration for smoother transitions.
		velocity.x = move_toward(
			velocity.x, 
			speed * SPRINT_MULTIPLIER, 
			SPRINT_ACCELERATION
			)
		camera.call("start_shake")
		camera.call("set_zoom_factor", 0.5)
		in_sprint_zone = true


func _on_zones_exited(area: Area2D) -> void:
	# Reset speed when leaving zone.
	if area and area.has_meta("sprintzone"):
		in_sprint_zone = false
		camera.call("start_shake")
		camera.reset_zoom()
		# Gradually resotres player speed after leaving speint zone.
		# Deceleration for smoother transitions.
		velocity.x = move_toward(
			velocity.x, 
			sign(velocity.x) * sprint_target_speed, 
			SPRINT_DECELERATION * get_physics_process_delta_time()
		)


# ===============
# SOUND HANDLING
# ===============
func start_running_sound() -> void:
	if not running_sound_player.playing:
		running_sound_player.play()


func stop_running_sound() -> void:
	if running_sound_player.playing:
		running_sound_player.stop()


func start_sliding_sound() -> void:
	if not sliding_sound_player.playing:
		sliding_sound_player.play()


func stop_sliding_sound() -> void:
	if sliding_sound_player.playing:
		sliding_sound_player.stop()


#=================
# DEATH HANDLING
# ================
# Triggers slow motion, animation, and restart timer on death.
func _on_lethal_entered(area: Area2D) -> void:
	if area and area.has_meta("lethal") and not is_death:
		is_death = true
		Engine.time_scale = 0.3
		velocity = Vector2.ZERO
		animated_sprite.play("death")
		death_cooldown.start()


# ================
# RESTART LEVEL
# ================
# Reset the scene after death cooldown ends.
func _on_death_cooldown_timeout() -> void:
	Engine.time_scale = 1.0
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)
