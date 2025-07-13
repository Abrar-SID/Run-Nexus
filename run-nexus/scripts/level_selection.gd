extends Control

@export var player_icon: TextureRect
@onready var worlds: Array = [$WorldIcon, $WorldIcon2, $WorldIcon3, $WorldIcon4]
var current_world: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_icon.global_position = worlds[current_world].global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("move_back") and current_world > 0:
		current_world -=1
		player_icon.global_position = worlds[current_world].global_position
		
	if event.is_action_pressed("move_front") and current_world < worlds.size() - 1:
		current_world +=1
		player_icon.global_position = worlds[current_world].global_position
