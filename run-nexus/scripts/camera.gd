extends Camera2D

const DEFAULT_SHAKE_STRENGTH: float = 20.0
const MAX_SHAKE_STRENGTH: float = 50.0

var shake_strength: float = 0.0
var shake_decay: float = 20.0

var target_zoom: Vector2 = Vector2.ONE
var zoom_speed: float = 1.0
var default_zoom: Vector2 = Vector2(2, 2)


# Handles camera shake and zoom logic
func _ready() -> void:
	zoom = default_zoom
	target_zoom = zoom


func start_shake(strength:float = DEFAULT_SHAKE_STRENGTH):
	if strength <= 0:
		push_warning("Shake strength should be positive. Using absolute value.")
		strength = abs(strength)
	shake_strength = clamp(strength, 0, MAX_SHAKE_STRENGTH)


func set_zoom_factor(factor: float):
	factor = clamp(factor, 0.3, 0.5)
	target_zoom = default_zoom * factor
	

func reset_zoom() -> void:
	target_zoom = default_zoom
	
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		var x_offset = randf_range(-shake_strength, shake_strength)
		var y_offset = randf_range(-shake_strength, shake_strength)
		offset = Vector2(x_offset, y_offset)
		shake_strength = move_toward(shake_strength, 0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
		
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
