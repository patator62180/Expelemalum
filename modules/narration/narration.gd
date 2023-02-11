extends Control


@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
enum AUDIO_LINE {Everyday , Exorcism, Intro}



func _on_timer_timeout():
	narratorStreamPlayer._play_line(AUDIO_LINE.keys()[AUDIO_LINE.Exorcism])
