extends Node2D

@export var pause_menu : MarginContainer
@export var game_ui : MarginContainer
@export var controls_menu : MarginContainer
@export var options_menu : MarginContainer
@export var home_menu : MarginContainer
@export var home_controls_menu : MarginContainer
@export var settings : MarginContainer
@export var home_settings : MarginContainer
@export var finish_menu : MarginContainer



var gameplay_scenes = ["level_1"]


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


func _on_toggle_controls_menu_button_pressed() -> void:
	toggle_visibility(pause_menu)
	toggle_visibility(controls_menu)


func _on_toggle_option_menu_button_pressed() -> void:
	toggle_visibility(home_menu)
	toggle_visibility(options_menu)


func _on_toggle_home_controls_menu_button_pressed() -> void:
	toggle_visibility(options_menu)
	toggle_visibility(home_controls_menu)


func _on_start_game_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_selection.tscn")


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_selection.tscn")


func _on_toggle_settinng_button_pressed() -> void:
	toggle_visibility(pause_menu)
	toggle_visibility(settings)


func _on_toggle_home_to_settings_button_pressed() -> void:
	toggle_visibility(options_menu)
	toggle_visibility(home_settings)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	

func level_finished_menu() -> void:
	pass
