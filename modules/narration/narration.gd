extends Control


@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready
var narratorSubtitleLabel : Label = get_node("Label")
enum AUDIO_LINE {Everyday , Exorcism, Intro, TooMuchTrigger}

func _ready():
	GameState.updated.connect(_on_game_state_updated)

func _play_line(lineName : AUDIO_LINE):
	var lineNameStr = AUDIO_LINE.keys()[lineName]
	var subtitledAudioStream = load("res://modules/narration/Audio/"+lineNameStr+".tres")
	if subtitledAudioStream != null:
		narratorStreamPlayer.stream = subtitledAudioStream.Audio
		narratorSubtitleLabel.text = subtitledAudioStream.SubtitleText
	else:
		var audioStream = load("res://modules/narration/Audio/AudioSource/"+lineNameStr+".wav")
		narratorStreamPlayer.stream = audioStream
		narratorSubtitleLabel.text = "No Subtitle"
	narratorStreamPlayer.play()

func _on_game_state_updated():
	if(GameState.KillCount == 1):
		_play_line(AUDIO_LINE.Everyday)


func _on_audio_stream_player_finished():
	narratorSubtitleLabel.text = ""
