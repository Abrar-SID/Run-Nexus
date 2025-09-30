extends CharacterBody2D

# ==CONSTANTS==
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = -300.0
const WALL_SLIDE_SPEED = 50.0
const WALL_SLIDE_FRICTION = 2000.0

# ==VARIABLES==
var speed = 300.0
var in_sprintzone: bool = false
var is_wall_sliding: bool = false
var was_on_floor: bool = false
var is_landing: bool = false
var jump_zone_animation: String = "jump"
var facing_direction := 1

# ==EXPORTS==
@export var jump_sound: Node
@export var land_sound: Node
@export var run_sound: Node
@export var wall_slide_sound: Node

# ==NODES==
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_left: RayCast2D = $LeftWallDetector
@onready var wall_right: RayCast2D = $RightWallDetector
@onready var general_collision: CollisionShape2D = $GeneralCollision
@onready var zone_detector: Area2D = $ZoneDetector
@onready var wall_jump_cooldown: Timer = $Timers/WallJumpCooldown
@onready var death_cooldown: Timer = $Timers/DeathCooldown
@onready var falling_countdown: Timer = $Timers/FallingCountdown
@onready var landing_cooldown: Timer = $Timers/LandingCooldown




func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	if not is_landing:
		handle_jump()
		handle_wall_slide(delta)
		handle_wall_jump()
		handle_movement()
	handle_animation()
	move_and_slide()
	
	if not is_on_floor() and not falling_countdown.is_stopped():
		pass
	elif not is_on_floor() and falling_countdown.is_stopped():
		falling_countdown.start()
	elif is_on_floor() and falling_countdown.time_left > 0.75:
		start_landing()


# ==GRAVITY==
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# ==JUMP==
func handle_jump() -> void:
	if in_sprintzone:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# ==LAND==
func start_landing() -> void:
	is_landing = true
	velocity = Vector2.ZERO
	animated_sprite.play("land")
	landing_cooldown.start()


func _on_landing_cooldown_timeout() -> void:
	is_landing = false


# ==WALL SLIDE==
func handle_wall_slide(delta: float) -> void:
	var was_sliding = is_wall_sliding
	is_wall_sliding = false

	if is_on_floor() or not wall_jump_cooldown.is_stopped():
		if was_sliding:
			wall_slide_sound.stop()
		return
		
	var on_left = wall_left.is_colliding()
	var on_right = wall_right.is_colliding()
	var pressing_left = Input.is_action_pressed("move_back")
	var pressing_right = Input.is_action_pressed("move_front")
	
	if (on_left or on_right) and velocity.y > 0:
		is_wall_sliding = true
		if not was_sliding:
			wall_slide_sound.play()
			
		if (on_left and pressing_left) or (on_right and pressing_right):
			velocity.y = move_toward(velocity.y, 0, WALL_SLIDE_FRICTION * delta)
		else:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_FRICTION * delta)
	else:
		if was_sliding:
			wall_slide_sound.stop()


# ==WALL JUMP==
func handle_wall_jump() -> void:
	if is_on_floor() or in_sprintzone:
		return
		
	var on_left = wall_left.is_colliding()
	var on_right = wall_right.is_colliding()
	
	if Input.is_action_just_pressed("jump") and (on_left or on_right) and wall_jump_cooldown.is_stopped():
		velocity.y = WALL_JUMP_VELOCITY
		if on_left:
			velocity.x = speed
			facing_direction = -1
			animated_sprite.flip_h = true
		elif on_right:
			velocity.x = -speed
			facing_direction = 1
			animated_sprite.flip_h = false
		is_wall_sliding = false
		jump_sound.play()
		wall_jump_cooldown.start()
		


# ==MOVEMENT==
func handle_movement() -> void:
	if in_sprintzone:
		velocity.x = move_toward(velocity.x, speed * 2, 20)
		animated_sprite.flip_h = false
	else:
		var direction := Input.get_axis("move_back", "move_front")
		if direction:
			velocity.x = direction * speed
			
			if direction > 0:
				facing_direction = 1
				animated_sprite.flip_h = false
			elif direction < 0:
				facing_direction = -1
				animated_sprite.flip_h = true
		else:
			velocity.x = move_toward(velocity.x, 0, speed)


# HANDLING ANIMATION
func handle_animation() -> void:
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			if in_sprintzone:
				animated_sprite.play("sprint")
			else:
				animated_sprite.play("run")
			
	else:
		if is_wall_sliding:
			animated_sprite.play("wall_slide")
			if Input.is_action_just_pressed("jump"):
				animated_sprite.play("wall_jump")
				return
			elif velocity.y < 0:
				animated_sprite.play(jump_zone_animation)
			else:
				animated_sprite.play("fall")


# ENTER ZONE
func _on_zone_detector_area_entered(area: Area2D) -> void:
	if area.has_meta("jump_2"):
		jump_zone_animation = "jump_2"
	elif area.has_meta("jump_3"):
		jump_zone_animation = "jump_3"
	
	if area.has_meta("sprintzone"):
		in_sprintzone = true


# EXIT ZONE
func _on_zone_detector_area_exited(area: Area2D) -> void:
	if area.has_meta("jump_2") or area.has_meta("jump_3"):
		jump_zone_animation = "jump"
	
	if area.has_meta("sprintzone"):
		in_sprintzone = false
		velocity.x = 0


# HANDLING DEATH
func _on_lethal_entered(area: Area2D) -> void:
	if area.has_meta("lethal"):
		Engine.time_scale = 0.2
		animated_sprite.play("death")
		death_cooldown.start()


# RESTART LEVEL
func _on_death_cooldown_timeout() -> void:
	Engine.time_scale = 1.0
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)
