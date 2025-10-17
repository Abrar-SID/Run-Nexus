extends CanvasLayer

# ==========
# TRANSITION MANAGER PURPOSE
# ==========
# Handling fade in/out screen transitions for scene changes and quitting.
# Using tween-based opacity control for smooth visual transitions.

# ========
# NODE REFERENCES
# ========
# The full-screen rectangle used to fade in and out during transitions.
@onready var fade_rect: ColorRect = $FadeRect

# ========
# EXPORT VARIABLES
# ========
# Cntrols how long the fade effect lasts and how long the screen stays black.
@export var fade_time: float = 0.5
@export var black_pause: float = 0.2


# ========
# INITIALIZATION
# ========
# Hides the fade overlay and sets it fully transparent on startup.
func _ready() -> void:
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0


# ========
# NODE REFERENCES
# ========
# Handles the full fade sequence: fade out, pause, run callback, fade in.
# Callback = a function that runs while the screen is black, i.e. scene change.
func do_transition(callback: Callable) -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0

	var tween = create_tween()
	
	# Fade out: screen to black
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_time)
	# Pause while screen is black (scene loads or quits here).
	tween.tween_interval(black_pause)
	# Execute the callback function during black screen.
	tween.tween_callback(callback)
	# Fade in: screen back to visible.
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_time)
	# Hide the fade overlay after transition complete.
	tween.tween_callback(func():
		fade_rect.visible = false
	)


# ========
# SCENE MANAGEMENT
# ========
#Fades to the specified scene path safely if the resource exists.
func fade_to_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	do_transition(func():
		get_tree().change_scene_to_file(path)
	)


# ========
# APPLICATION EXIT
# ========
# Runs a fade out before quitting the game.
func fade_and_quit() -> void:
	do_transition(func():
		get_tree().quit()
	)
