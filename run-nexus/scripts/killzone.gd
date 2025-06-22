extends Area2D

#Variables here:
@onready var timer: Timer = $Timer

#Detection of player entering:
func _on_player_entered(body: Node2D) -> void:
	print("You died!")
	Engine.time_scale = 0.2
	body.get_node("CollisionShape2D").queue_free()
	timer.start()
	
#World timer:
func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
