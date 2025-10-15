@tool
extends Control

# ============
# LEVEL LABEL DISPLAY SCRIPT PURPOSE
# ============
# Displaying the current level number on a Label node.
# Updating automatically both in-game and in the editor.

@onready var label: Label = $Label
@export var level_index: int = 1


# =================
# LEVEL LABEL SETUP
# =================
# Called when the node enters the scene tree for the first time.
# Ensures the level index is valid and updates the on-screen label.
func _ready() -> void:
	level_index = clamp(level_index, 1, 4)
	label.text = "Level %d" % level_index


# ============
# EDITOR UPDATE
# ============
# Updates label in the editor when  changing level_index.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		label.text = "Level %d" % level_index
