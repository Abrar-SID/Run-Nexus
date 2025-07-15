extends Node2D

@export var pause_menu : MarginContainer
@export var game_ui : MarginContainer
@export var controls_menu : MarginContainer
@export var options_menu : MarginContainer
@export var home_menu : MarginContainer
@export var home_controls_menu : MarginContainer


func toggle_visibility(object) ->void:
	if object.visible:
		object.visible = false
	else:
		object.visible = true


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
