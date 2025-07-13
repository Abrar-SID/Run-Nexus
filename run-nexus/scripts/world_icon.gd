@tool
extends Control

@onready var label: Label = $Label
@export var level_index: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Level" + str(level_index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		label.text = "Level" + str(level_index)
