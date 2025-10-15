extends Camera2D

# ================================
# SCRIPT PURPOSE
# ================================
# Managing the camera’s shake and zoom effects.
# Ceating smooth zoom transitions and random screen shake.
# Giving visual feedback during impacts or intense actions like sprint.

# ========
# CONSTANTS FOR SHAKE
# ========
# Default shake strenght when triggered.
const DEFAULT_SHAKE_STRENGTH: float = 20.0
const MAX_SHAKE_STRENGTH: float = 50.0

# ==========
# VARIABLES FOR SCREEN SHAKE AND ZOOM
# ==========
# Current shake strenght. Reduced over time in _process().
var shake_strength: float = 0.0
# Rate at which shake_strength diminishes per second.
var shake_decay: float = 20.0
# Target zoom level for smooth interpolation.
var target_zoom: Vector2 = Vector2.ONE
# Speed factor for lerping zoom.
var zoom_speed: float = 1.0
# Default zoom value (no scaling applied).
var default_zoom: Vector2 = Vector2(2, 2)


# ============
# INITIALIZATION
# ============
# Set default zoom when scene starts.
func _ready() -> void:
	zoom = default_zoom
	target_zoom = zoom


# ============
# SHAKE FUNCTIONS
# ============
# Starts screen shake effect with optional strength parameter.
# Clamps strength to avoid excessive shaking.
func start_shake(strength:float = DEFAULT_SHAKE_STRENGTH):
	if strength <= 0:
		push_warning("Shake strength should be positive. Using absolute value.")
		strength = abs(strength)
	shake_strength = clamp(strength, 0, MAX_SHAKE_STRENGTH)


# Sets zoom factor relative to default zoom.
# Smaller factors zoom in, larger factors zoom out.
func set_zoom_factor(factor: float):
	factor = clamp(factor, 0.3, 0.5) # Prevents extreme zoomv values.
	target_zoom = default_zoom * factor


# Reset zoom to default instantly.
func reset_zoom() -> void:
	target_zoom = default_zoom


# ============
# FRAME UPDATE
# ============
func _process(delta: float) -> void:
	if shake_strength > 0:
		# Apply random offsets withing current shake strength range.
		var x_offset = randf_range(-shake_strength, shake_strength)
		var y_offset = randf_range(-shake_strength, shake_strength)
		offset = Vector2(x_offset, y_offset)
		# Reduce shake_strenght over time to gradually stop shaking.
		shake_strength = move_toward(shake_strength, 0, shake_decay * delta)
	else:
		# No shake, camera offset is neutral.
		offset = Vector2.ZERO
	
	# Smoothly interpolate zoom to target_zoom.
	# Prevents abrupt snapping when zoom changes.
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
