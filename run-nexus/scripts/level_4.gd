extends Node2D


# Called when the node enters the scene tree for the first time.
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var ui = $CanvasLayer/generalUI


func _on_level_4_end_zone_body_entered(body: Node2D) -> void:
	if body == player:
		ui.level_finished_menu_4()
