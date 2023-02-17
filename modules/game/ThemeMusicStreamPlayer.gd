extends AudioStreamPlayer

@export var audio_bus_name : String = "ThemeMusic"

@onready var audio_bus_index : int = AudioServer.get_bus_index(audio_bus_name)

const standard_volume : float = 0
const low_volume : float = -10
const fade_duration : float = 0.5

func toggle_down_volume(toggle : bool):
	var from = standard_volume if toggle else low_volume
	var to = low_volume if toggle else standard_volume
	create_tween().bind_node(self).tween_method(set_volume, from, to, fade_duration)


func set_volume(volume : float):
	AudioServer.set_bus_volume_db(audio_bus_index, volume)
