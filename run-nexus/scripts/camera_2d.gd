extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 20.0

func start_shake(strength:float = 5.0):
	shake_strength = strength
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		shake_strength = move_toward(shake_strength, 0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

#@export var stop_x: float = 2000.0
#@onready var player: CharacterBody2D = $"../player"
#@onready var camera: Camera2D = $"."

#func _ready() -> void:
#	camera.is_current()
	
#func _process(_delta: float) -> void:
#	var new_pos = global_position
	
#	if player.global_position.x < stop_x:
#		new_pos.x = player.global_position.x
#	else:
#		new_pos.x = stop_x
	
#	new_pos.y = player.global_position.y
#	global_position = new_pos
