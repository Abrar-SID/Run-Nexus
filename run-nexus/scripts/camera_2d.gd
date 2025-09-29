extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 20.0

func start_shake(strength:float = 5.0):
	shake_strength = strength
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		shake_strength = move_toward(shake_strength, 0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
