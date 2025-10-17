extends Node2D

# =========================
# LEVEL END TRIGGER (LEVEL 2) PURPOSE
# =========================
# Handling detection when player reaches end zone and triggers finish menu.

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var ui: Node2D = $CanvasLayer/generalUI


# Triggers level completion when player enters the end zone.
# If the scene hierarchy is incomplete, there will be errors.
# So checks if the UI node exists first to prevent errors.
# Ensures only the player (not other physics bodies) activaties the level end.
func _on_level_2_end_zone_body_entered(body: Node2D) -> void:
	if not ui:
		push_error("UI node missing")
		return

	if body and body == player and ui:
		ui.level_finished_menu_2()
		print("Level 2 end zone triggered.")
