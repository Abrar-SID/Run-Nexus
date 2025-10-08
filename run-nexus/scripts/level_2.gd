extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var ui: Node2D = $CanvasLayer/generalUI

func _on_level_2_end_zone_body_entered(body: Node2D) -> void:
	if body == player:
		ui.level_finished_menu_2()
