extends HSlider

# =================
# SCRIPT PURPOSE
# =================
# Linking a volume slider to an audio bus in the project.
# Converting the slider’s linear value into decibels.
# Updating the corresponding audio bus volume in real time.

# ============
# AUDIO BUS CONTROL
# ============
# Name of the AudioServerr bus that this slider will control.
# Must match exactly with the bus name in the project settings.
@export var audio_bus_name: String

# Stores the resolved index of the audio bus.
# Used for efficiently set the volume wihtout repeatedly looking up.
var audio_bus_id: int


# ============
# INITIALIZATION
# ============
# Resolve the audio bus index when the nodeis ready.
# Pushes error if the bus neame is invalid, preventing runtime failures.
func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		push_error("Invalid audio bus name:" + audio_bus_name)


# ============
# SLIDER VLAUE CHANGE HANDLER
# ============
# Adjust bus volume when slider value changes/ slider is moved.
# Clamp slider input to [0, 1] to prevent invalid values.
# Converts linear slider values to decibels (AudioServer requieres dB).
func _on_value_changed(new_value: float) -> void:
	new_value = clamp(new_value, 0.0, 1.0)
	var db = linear_to_db(new_value)
	if audio_bus_id != -1:
		AudioServer.set_bus_volume_db(audio_bus_id, db)
