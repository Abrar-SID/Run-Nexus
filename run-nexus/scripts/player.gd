extends CharacterBody2D

#Nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var ray_right: RayCast2D = $raycastRight
@onready var ray_left: RayCast2D = $raycastLeft

#Contstants
const JUMP_VELOCITY = -600.0
const WALL_JUMP_PUSHBACK = -400.0
const WALL_SLIDE_SPEED = 100.0
const WALL_SLIDE_FRICTION = 1000.0
const WALL_JUMP_LOCK_FRAMES = 10

#Variables
var speed= 250.0
var current_jump_animation = "falling"
var in_sprintzone= false
var wall_jump_frames = 0
var is_wall_sliding = false



#Add the Movement: Jump, Run, Slide
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite.play("jump_2")
		# Add the gravity.
	velocity += get_gravity() * delta
	
	handle_wall_slide(delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if Input.is_action_just_pressed("jump") and is_on_floor() and not in_sprintzone:
			velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_back" , "move_front")
	
	if wall_jump_frames > 0:
		wall_jump_frames -= 1
	else: 
		if in_sprintzone and is_on_floor():
			direction = 1
			animated_sprite.flip_h = false
		else:
			direction = Input.get_axis("move_back", "move_front")
			if direction < 0:
				animated_sprite.flip_h = true
			elif direction > 0:
				animated_sprite.flip_h = false

	
	#fliping sprite.
	if Input.is_action_pressed("move_back"):
		animated_sprite.flip_h = true
	if Input.is_action_pressed("move_front"):
		animated_sprite.flip_h = false
		
	#Action animations.
	if is_on_floor():
		if is_on_floor() and not is_wall_sliding:
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		elif not is_on_floor() and not is_wall_sliding:
			animated_sprite.play(current_jump_animation)
	
	if wall_jump_frames == 0:
		if in_sprintzone and is_on_floor():
			velocity.x = speed
		else:
			if direction:
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
		
		
	#Handle wall jump here
	handle_walljump()
	
	#Finish by adding MOVE
	move_and_slide()
	

func handle_wall_slide(delta: float) -> void:
	is_wall_sliding = false
	if is_on_floor():
		return

	if wall_jump_frames > 0:
		return

	var on_left = ray_left.is_colliding()
	var on_right = ray_right.is_colliding()
	var pressing_left = Input.is_action_pressed("move_back")
	var pressing_right = Input.is_action_pressed("move_front")
	var slide_left = on_left and pressing_left
	var slide_right = on_right and pressing_right
	
	if (slide_left or slide_right) and velocity.y >= 0.0:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_FRICTION * delta)
		is_wall_sliding = true
		animated_sprite.play("wall_slide")

#Code wall jump here
func handle_walljump() -> void:
	if is_on_floor() or in_sprintzone:
		return
	
	if wall_jump_frames > 0:
		return
		
	var on_left_wall = ray_left.is_colliding()
	var on_right_wall = ray_right.is_colliding()
	
	if Input.is_action_just_pressed("jump"):
		if on_left_wall:
			velocity.x = speed
			velocity.y = WALL_JUMP_PUSHBACK
			animated_sprite.flip_h = false
			current_jump_animation = "jump_1"
			wall_jump_frames = WALL_JUMP_LOCK_FRAMES
		elif on_right_wall:
			velocity.x = -speed
			velocity.y = WALL_JUMP_PUSHBACK
			animated_sprite.flip_h = true
			current_jump_animation = "jump_1"
			wall_jump_frames  = WALL_JUMP_LOCK_FRAMES
			
		is_wall_sliding = false


# ---------------------------
# AREA2D SIGNALS
# ---------------------------
func _on_zones_entered(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		speed = 1000.0
		camera.call("tart_shake")
		in_sprintzone = true
		
	if area.has_meta("ani_jump_1"):
		current_jump_animation = "jump_1"
	elif area.has_meta("ani_jump_2"):
		current_jump_animation = "jump_2"
	elif area.has_meta("ani_jump_3"):
		current_jump_animation = "jump_3"
	

func _on_zones_exited(area: Area2D) -> void:
	if area.has_meta("sprintzone"):
		speed = 200.0
		in_sprintzone = false
		
	if area.has_meta("jump_ani_1") or area.has_meta("jump_ani_2") or area.has_meta("jump_ani_3"):
		# Reset to default jump animation when leaving jump zone
		current_jump_animation = "jump_1"


#Code death  here
func _on_lethal_entered(area: Area2D) -> void:
	if area.has_meta("lethal"):
		call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()
