extends Control


@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready
var narratorSubtitleLabel : Label = get_node("Label")
enum AUDIO_LINE {Everyday , Exorcism, Intro, TooMuchTrigger}



func _on_timer_timeout():
	_play_line(AUDIO_LINE.Exorcism)


func _on_game_state_trigger_intro_line():
	_play_line(AUDIO_LINE.Everyday)


func _on_game_state_trigger_intro_line_too_much():
	_play_line(AUDIO_LINE.TooMuchTrigger)


func _play_line(lineName : AUDIO_LINE):
	var lineNameStr = AUDIO_LINE.keys()[lineName]
	var subtitledAudioStream = load("res://modules/narration/Audio/"+lineNameStr+".tres")
	if subtitledAudioStream != null:
		narratorStreamPlayer.stream = subtitledAudioStream.Audio
		narratorSubtitleLabel.text = subtitledAudioStream.SubtitleText
	else:
		var audioStream = load("res://modules/narration/Audio/"+lineNameStr+".wav")
		narratorStreamPlayer.stream = audioStream
	narratorStreamPlayer.play()
