extends Node2D

@export var pause_menu : MarginContainer
@export var game_ui : MarginContainer
@export var controls_menu : MarginContainer
@export var options_menu : MarginContainer
@export var home_menu : MarginContainer
@export var home_controls_menu : MarginContainer

func toggle_visibilty(object) ->void:
	if object.visible:
		object.visible = false
	else:
		object.visible = true


func _on_toggle_pause_menu_button_pressed() -> void:
	toggle_visibilty(pause_menu)
	toggle_visibilty(game_ui)


func _on_toggle_controls_menu_button_pressed() -> void:
	toggle_visibilty(pause_menu)
	toggle_visibilty(controls_menu)


func _on_toggle_option_menu_button_pressed() -> void:
	toggle_visibilty(home_menu)
	toggle_visibilty(options_menu)


func _on_toggle_home_controls_menu_button_pressed() -> void:
	toggle_visibilty(options_menu)
	toggle_visibilty(home_controls_menu)
