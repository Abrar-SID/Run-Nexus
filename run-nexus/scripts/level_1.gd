extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var black_rect: ColorRect = $CanvasLayer/ColorRect
@onready var ui: Node2D = $CanvasLayer/generalUI
@onready var level_end: Area2D = $levelEnd


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
	black_rect.modulate.a = 1.0
	after_fade()
	

func after_fade() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui.tscn")
