extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var black_rect: ColorRect = $CanvasLayer/ColorRect
@onready var ui: Node2D = $CanvasLayer/generalUI

var FADE_STARTED = false

@export var fade_buffer: float = 32.0
@export var fade_time: float = 0.8

func _ready() -> void:
	black_rect.visible = false
	black_rect.modulate.a = 0.0


func _on_level_end_body_entered(body: Node2D) -> void:
	if body == player and get_node("levelEnd").has_meta("levelend"):
		if not FADE_STARTED:
			FADE_STARTED = true
			start_fade()
			
		
func start_fade() -> void:
	black_rect.visible = true
	black_rect.modulate.a = 0.0
	
	var tween = create_tween()
	
	tween.tween_property(black_rect, "modulate:a", 1.0, fade_time)
	tween.tween_callback(func() -> void:
		$CanvasLayer/generalUI/finishMenu.visible = true
		$CanvasLayer/generalUI/inGameUI.visible = false
		player.set_physics_process(false)
	)
