extends Node2D

# ======
# GENERAL UI MANAGER PURPOSE
# ======
# Controlling all in-game and home UI menus.
# Handling scene transitions, pause menus, and finish screens using the Transition system.
# Ensuring consistent visibility and fade logic across gameplay and UI states.

# =========
# PATH CONSTANTS
# =========
const LEVEL_PATHS = [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn"
]
const HOME_PATH: String = "res://scenes/ui.tscn"
const LEVEL_SELECTION_PATH: String = "res://scenes/level_selection.tscn"

# ============
# UI ELEMENT REFERENCES
# ============
@export var pause_menu : MarginContainer
@export var game_ui : MarginContainer
@export var controls_menu : MarginContainer
@export var options_menu : MarginContainer
@export var home_menu : MarginContainer
@export var home_controls_menu : MarginContainer
@export var settings : MarginContainer
@export var home_settings : MarginContainer
@export var finish_menu_1 : MarginContainer
@export var finish_menu_2 : MarginContainer
@export var finish_menu_3 : MarginContainer
@export var finish_menu_4 : MarginContainer

var gameplay_scenes = ["level_1", "level_2", "level_3", "level_4"]


# =========
# INITIAL SETUP
# =========
func _ready() -> void:
	var current_scene_name = get_tree().current_scene.name
	# Show correct menu based on current scene.
	if current_scene_name in gameplay_scenes:
		home_menu.visible = false
		game_ui.visible = true
	else:
		home_menu.visible = true
		game_ui.visible = false


# ===========
# MENU TOGGLE FUNCTIONS
# ===========
# For switching menus easily. 
# Transition(fade in and out) is used for smooth visual transitions.
func toggle_visibility(object) -> void:
	Transition.do_transition(func():
		object.visible = not object.visible
	)


# Switch visibility between pause menu and game UI
func _on_toggle_pause_menu_button_pressed() -> void:
	Transition.do_transition(func():
		pause_menu.visible = not pause_menu.visible
		game_ui.visible = not game_ui.visible
	)


# Switch visibility between pause menu and controls menu
func _on_toggle_controls_menu_button_pressed() -> void:
	Transition.do_transition(func():
		pause_menu.visible = not pause_menu.visible
		controls_menu.visible = not controls_menu.visible
	)


# Switch visibility between home menu and options menu
func _on_toggle_option_menu_button_pressed() -> void:
	Transition.do_transition(func():
		home_menu.visible = not home_menu.visible
		options_menu.visible = not options_menu.visible
	)


# Switch visibility between options menu and home controls menu
func _on_toggle_home_controls_menu_button_pressed() -> void:
	Transition.do_transition(func():
		options_menu.visible = not options_menu.visible
		home_controls_menu.visible = not home_controls_menu.visible
	)


# Scene changes between home menu and level selection menu
func _on_start_game_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_SELECTION_PATH)


# Restarts current level/scene.
func _on_restart_button_pressed() -> void:
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)


# Exits the level and returns to level selection menu.
func _on_quit_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_SELECTION_PATH)


# Switch visibility between settings menu and pause menu
func _on_toggle_settings_button_pressed() -> void:
	Transition.do_transition(func():
		settings.visible = not settings.visible
		pause_menu.visible = not pause_menu.visible
	)


# Switch visibility between options menu and home settings menu
func _on_toggle_home_to_settings_button_pressed() -> void:
	Transition.do_transition(func():
		options_menu.visible = not options_menu.visible
		home_settings.visible = not home_settings.visible
	)


# Exiting the game.
func _on_exit_button_pressed() -> void:
	Transition.fade_and_quit()
	

# ====================
# LEVEL FINISH MENUS
# ====================
func show_finish_menu(index: int) -> void:
	var finish_menu = [
		finish_menu_1,
		finish_menu_2,
		finish_menu_3,
		finish_menu_4
	]
	for menu in finish_menu + [
		pause_menu, game_ui, controls_menu, options_menu,
		home_menu, home_controls_menu, settings, home_settings
	]:
		menu.visible = false
	finish_menu[index].visible = true


func level_finished_menu_1() -> void:
	# Show finish menu for level 1 and hide others.
	Transition.do_transition(func(): show_finish_menu(0))


func level_finished_menu_2() -> void:
		# Show finish menu for level 2 and hide others.
		Transition.do_transition(func(): show_finish_menu(1))
	
	
func level_finished_menu_3() -> void:
		# Show finish menu for level 3 and hide others.
	Transition.do_transition(func(): show_finish_menu(2))


func level_finished_menu_4() -> void:
		# Show finish menu for level 4 and hide others.
	Transition.do_transition(func(): show_finish_menu(3))

# Next level buttons in the finish menus change scene to next level in order.
func _on_continue_level_2_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[1])


func _on_continue_level_3_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[2])


func _on_continue_level_4_button_pressed() -> void:
	Transition.fade_to_scene(LEVEL_PATHS[3])


func _on_continue_home_button_pressed() -> void:
	Transition.fade_to_scene(HOME_PATH)
