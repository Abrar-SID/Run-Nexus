extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		push_error("Invalid audio bus name:" + audio_bus_name)


func _on_value_changed(new_value: float) -> void:
	new_value = clamp(new_value, 0.0, 1.0)
	var db = linear_to_db(new_value)
	if audio_bus_id != -1:
		AudioServer.set_bus_volume_db(audio_bus_id, db)
