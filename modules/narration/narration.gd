extends Control


@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
enum AUDIO_LINE {Everyday , Exorcism, Intro, TooMuchTrigger}



func _on_timer_timeout():
	narratorStreamPlayer._play_line(AUDIO_LINE.keys()[AUDIO_LINE.Exorcism])


func _on_game_state_trigger_intro_line():
	narratorStreamPlayer._play_line(AUDIO_LINE.keys()[AUDIO_LINE.Everyday])


func _on_game_state_trigger_intro_line_too_much():
	narratorStreamPlayer._play_line(AUDIO_LINE.keys()[AUDIO_LINE.TooMuchTrigger])
