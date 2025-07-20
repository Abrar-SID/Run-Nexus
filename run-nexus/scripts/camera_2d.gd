#extends Camera2D

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
