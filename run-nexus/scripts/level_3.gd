extends Node2D


@onready var player: CharacterBody2D = $CharacterBody2D
@onready var ui = $CanvasLayer/generalUI


func _on_level_3_end_zone_body_entered(body: Node2D) -> void:
	if not ui:
		push_error("UI node missing")
		return

	if body and body == player and ui:
		ui.level_finished_menu_3()
