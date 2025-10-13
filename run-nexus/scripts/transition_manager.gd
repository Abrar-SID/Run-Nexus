extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

@export var fade_time: float = 0.5
@export var black_pause: float = 0.1


func _ready() -> void:
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func do_transition(callback: Callable) -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0

	var tween = create_tween()
	
	# fade out to black
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_time)
	# pause while screen is black
	tween.tween_interval(black_pause)
	# switch of scenes
	tween.tween_callback(callback)
	
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_time)
	
	tween.tween_callback(func():
		fade_rect.visible = false
	)


func fade_to_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	do_transition(func():
		get_tree().change_scene_to_file(path)
	)


func fade_and_quit() -> void:
	do_transition(func():
		get_tree().quit()
	)
