extends Control

@export var player_icon: TextureRect
@onready var worlds: Array = [$WorldIcon, $WorldIcon2, $WorldIcon3, $WorldIcon4]
var current_world: int = 0
var level_infos: Array

@export var level_1_info: NinePatchRect
@export var level_2_info: NinePatchRect
@export var level_3_info: NinePatchRect
@export var level_4_info: NinePatchRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_icon.global_position = worlds[current_world].global_position
	level_infos = [level_1_info, level_2_info, level_3_info, level_4_info]
	show_only_level_info(current_world)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("move_back") and current_world > 0:
		current_world -=1
		player_icon.global_position = worlds[current_world].global_position
		show_only_level_info(current_world)
		
	if event.is_action_pressed("move_front") and current_world < worlds.size() - 1:
		current_world +=1
		player_icon.global_position = worlds[current_world].global_position
		show_only_level_info(current_world)
		

func show_only_level_info(level_index: int) ->void:
	for i in range(level_infos.size()):
		level_infos[i].visible = (i == level_index)
		

func move_to_world(index:int) -> void:
	current_world = index
	player_icon.global_position = worlds[index].global_position
	show_only_level_info(index)


func _on_level_2_button_pressed() -> void:
	if not level_2_info.visible:
		move_to_world(1)
		
	
func _on_level_1_button_pressed() -> void:
	if not level_1_info.visible:
		move_to_world(0)

func _on_level_3_button_pressed() -> void:
	if not level_3_info.visible:
		move_to_world(2)

func _on_level_4_button_pressed() -> void:
	if not level_4_info.visible:
		move_to_world(3)


func _on_level_start_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_1.tscn")


func _on_back_to_home_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui.tscn")
