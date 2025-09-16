extends Node2D

@onready var player : CharacterBody2D = $CharacterBody2D

func _on_level_end_zone_body_entered(body: Node2D) -> void:
	if body == player and get_node("LevelEnd").has_meta("level_end"):
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui.tscn")
