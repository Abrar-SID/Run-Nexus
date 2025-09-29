extends Node2D

@export var pause_menu : MarginContainer
@export var game_ui : MarginContainer
@export var controls_menu : MarginContainer
@export var options_menu : MarginContainer
@export var home_menu : MarginContainer
@export var home_controls_menu : MarginContainer
@export var settings : MarginContainer
@export var home_settings : MarginContainer
@export var finish_menu_1 : MarginContainer
@export var finish_menu_2: MarginContainer
@export var finish_menu_3 : MarginContainer
@export var finish_menu_4 : MarginContainer



var gameplay_scenes = ["level_1", "level_2", "level_3", "level_4"]


func _ready():
	var current_scene_name = get_tree().current_scene.name

	if current_scene_name in gameplay_scenes:
		home_menu.visible = false
		game_ui.visible = true
	else:
		home_menu.visible = true
		game_ui.visible = false
	Transition.fade_in()


func toggle_visibility(object) ->void:
	if object.visible:
		object.visible = false
	else:
		object.visible = true
	Transition.fade_in()


func _on_toggle_pause_menu_button_pressed() -> void:
	toggle_visibility(pause_menu)
	toggle_visibility(game_ui)
	Transition.fade_in()


func _on_toggle_controls_menu_button_pressed() -> void:
	toggle_visibility(pause_menu)
	toggle_visibility(controls_menu)
	Transition.fade_in()


func _on_toggle_option_menu_button_pressed() -> void:
	toggle_visibility(home_menu)
	toggle_visibility(options_menu)
	Transition.fade_in()


func _on_toggle_home_controls_menu_button_pressed() -> void:
	toggle_visibility(options_menu)
	toggle_visibility(home_controls_menu)
	Transition.fade_in()


func _on_start_game_button_pressed() -> void:
	Transition.fade_in()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_selection.tscn")


func _on_restart_button_pressed() -> void:
	Transition.fade_in()
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	Transition.fade_in()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_selection.tscn")


func _on_toggle_settinng_button_pressed() -> void:
	toggle_visibility(pause_menu)
	toggle_visibility(settings)
	Transition.fade_in()


func _on_toggle_home_to_settings_button_pressed() -> void:
	toggle_visibility(options_menu)
	toggle_visibility(home_settings)
	Transition.fade_in()


func _on_exit_button_pressed() -> void:
	Transition.fade_in()
	get_tree().quit()
	

func level_finished_menu_1() -> void:
	Transition.fade_in()
	pause_menu.visible = false
	game_ui.visible = false
	controls_menu.visible = false
	options_menu.visible = false
	home_menu.visible = false
	home_controls_menu.visible = false
	settings.visible = false
	
	home_settings.visible = false
	finish_menu_2.visible = false
	finish_menu_3.visible = false
	finish_menu_4.visible = false
	
	finish_menu_1.visible = true
	

func level_finished_menu_2() -> void:
	Transition.fade_in()
	pause_menu.visible = false
	game_ui.visible = false
	controls_menu.visible = false
	options_menu.visible = false
	home_menu.visible = false
	home_controls_menu.visible = false
	settings.visible = false
	
	home_settings.visible = false
	finish_menu_1.visible = false
	finish_menu_3.visible = false
	finish_menu_4.visible = false
	
	finish_menu_2.visible = true
	
	
func level_finished_menu_3() -> void:
	Transition.fade_in()
	pause_menu.visible = false
	game_ui.visible = false
	controls_menu.visible = false
	options_menu.visible = false
	home_menu.visible = false
	home_controls_menu.visible = false
	settings.visible = false
	
	home_settings.visible = false
	finish_menu_1.visible = false
	finish_menu_2.visible = false
	finish_menu_4.visible = false
	
	finish_menu_3.visible = true
	
	
func level_finished_menu_4() -> void:
	Transition.fade_in()
	pause_menu.visible = false
	game_ui.visible = false
	controls_menu.visible = false
	options_menu.visible = false
	home_menu.visible = false
	home_controls_menu.visible = false
	settings.visible = false
	
	home_settings.visible = false
	finish_menu_1.visible = false
	finish_menu_2.visible = false
	finish_menu_3.visible = false
	
	finish_menu_4.visible = true
	


func _on_continue_level_2_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_2.tscn")


func _on_continue_level_3_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_3.tscn")


func _on_continue_level_4_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_4.tscn")


func _on_continue_home_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui.tscn")
