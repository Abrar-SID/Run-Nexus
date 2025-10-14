extends Control

@onready var worlds: Array = [$WorldIcon, $WorldIcon2, $WorldIcon3, $WorldIcon4]

const LEVEL_PATHS = [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn"
]

@export var level_1_info: NinePatchRect
@export var level_2_info: NinePatchRect
@export var level_3_info: NinePatchRect
@export var level_4_info: NinePatchRect
@export var player_icon: TextureRect

var current_world: int = 0
var level_infos: Array[NinePatchRect]


# Controls world selection UI and scene transitions.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if worlds.is_empty() or not player_icon:
		push_error("Error: missing UI elements")
		return

	player_icon.global_position = worlds[current_world].global_position
	level_infos = [level_1_info, level_2_info, level_3_info, level_4_info]
	show_only_level_info(current_world)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_back") and current_world > 0:
		current_world -=1
		player_icon.global_position = worlds[current_world].global_position
		show_only_level_info(current_world)
		
	if event.is_action_pressed("move_front") and current_world < worlds.size() - 1:
		current_world +=1
		player_icon.global_position = worlds[current_world].global_position
		show_only_level_info(current_world)
		

func show_only_level_info(level_index: int) -> void:
	for i in range(level_infos.size()):
		level_infos[i].visible = (i == level_index)
		

func move_to_world(index:int) -> void:
	if index < 0 or index >= worlds.size():
		return # invalid index

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


func _on_level_1_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[0])


func _on_back_to_home_button_pressed() -> void:
	Transition.fade_to_scene("res://scenes/ui.tscn")


func _on_level_2_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[1])


func _on_level_3_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[2])


func _on_level_4_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[3])
