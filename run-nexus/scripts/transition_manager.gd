extends CanvasLayer


@export var fade_time: float = 0.8

@onready var fade_rect: ColorRect = $FadeRect



func _ready() -> void:
	fade_rect.visible = false
	fade_rect.modulate.a = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func fade_to_scene(path: String) -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_time)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(path)
		fade_in()
	)

func fade_in() -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_time)
	tween.tween_callback(func():
		fade_rect.visible = false
)
	
