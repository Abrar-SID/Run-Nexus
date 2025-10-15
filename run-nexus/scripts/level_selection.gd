extends Control

# ======
# LEVEL SELECTION SCENE PURPOSE
# ======
# Managing the world/level selection menu/UI.
# Handling black location marker/player icon navigation between world icons.
# Updating visible level info panels based on selection.
# Triggering scene transitions when levels are started or back/home buttons pressed.

# ==============
# NODE REFRENCES
# ==============
# Icons representing world posiion on map.
@onready var worlds: Array = [$WorldIcon, $WorldIcon2, $WorldIcon3, $WorldIcon4]

# =========
# CONTANTS
# =========
# Path to each playable level scene. Used for scene transitions.
const LEVEL_PATHS = [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn"
]
# Path to UI scene for returning home.
const UI_PATH: String = "res://scenes/ui.tscn"

# ========
# EXPORTED VARIABLES
# ========
# Each variable holds UI panel containing level specific information.
@export var level_1_info: NinePatchRect
@export var level_2_info: NinePatchRect
@export var level_3_info: NinePatchRect
@export var level_4_info: NinePatchRect
# The player icon/ black location marker that moves between world icons.
@export var player_icon: TextureRect

# ======
# VARIABLES
# =====
# Index of the currently selected world/level (0-based).
var current_world: int = 0
# List storing all level info panels for easy iteration and visibilty toggle.
var level_infos: Array[NinePatchRect]


# ================
# MAIN INITIALIZATION
# ================
func _ready() -> void:
	# Ensures essential nodes are assigned.
	if worlds.is_empty() or not player_icon:
		push_error("Error: missing UI elements")
		return
	
	# Set player icon to current world icon.
	player_icon.global_position = worlds[current_world].global_position
	# Store all level info panels in an array for iteration in show_only_level_info().
	level_infos = [level_1_info, level_2_info, level_3_info, level_4_info]
	# Show info for the initially selected world only.
	show_only_level_info(current_world)


# =========
# INPUT HANDLING
# =========
func _input(event: InputEvent) -> void:
	# Moves player icon left across the wolrd map using input.
	# Ensures current_world stays withinng valid bounds.
	if event.is_action_pressed("move_back") and current_world > 0:
		current_world -=1
		player_icon.global_position = worlds[current_world].global_position
		show_only_level_info(current_world)
	
	# Move player icon/ black marker right across the world map.
	if event.is_action_pressed("move_front") and current_world < worlds.size() - 1:
		current_world +=1
		player_icon.global_position = worlds[current_world].global_position
		show_only_level_info(current_world)


# =========
# HELPER METHODS
# =========
# Displayes only the UI panel for the currently selected level.
# Hides all other level info panels to avoid  clutter.
func show_only_level_info(level_index: int) -> void:
	for i in range(level_infos.size()):
		level_infos[i].visible = i == level_index


# Moves to a specific world by index.
# Used by UI buttons for direct selection.
# Includes bounds check to prevent invalid index errors.
func move_to_world(index:int) -> void:
	if index < 0 or index >= worlds.size():
		return # If invalid index, do nothing.
	
	current_world = index
	player_icon.global_position = worlds[index].global_position
	show_only_level_info(index)


# ==========
# SCENE TRANSITION BUTTONS
# ==========
# Each button triggers a transition to the corresponding level.
# Checks visibility first to prevent unnecessary moves.
func _on_level_1_button_pressed() -> void:
	if not level_1_info.visible:
		move_to_world(0)


func _on_level_2_button_pressed() -> void:
	if not level_2_info.visible:
		move_to_world(1)


func _on_level_3_button_pressed() -> void:
	if not level_3_info.visible:
		move_to_world(2)

func _on_level_4_button_pressed() -> void:
	if not level_4_info.visible:
		move_to_world(3)


# Start selected level uisng transition singleton for fade effect.
func _on_level_1_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[0])


func _on_level_2_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[1])


func _on_level_3_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[2])


func _on_level_4_start_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[3])


# Return to home UI scene.
func _on_back_to_home_button_pressed() -> void:
	Transition.fade_to_scene(UI_PATH)
