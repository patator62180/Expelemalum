extends Control
@onready
var lastLineSpoken : Timer = $LastLineSpoken
@onready
var subtitles : Dictionary = parseSubtitles()
@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready
var narratorSubtitleLabel : Label = get_node("Label")
enum AUDIO_LINE {Everyday , Exorcism, Intro, TooMuchTrigger, narration_ww_intro}

func _ready():
	GameState.updatedKill.connect(_on_game_state_kill)
	GameState.updatedTransformation.connect(_on_game_state_metamorph)
	
	var subtitles : Dictionary = parseSubtitles()
	lastLineSpoken.start()

func parseSubtitles(
	id_column: String = "id",
	delimiter: String = ","
) -> Dictionary:
	var file = FileAccess.open("res://modules/narration/Audio/Audio - narrationDictionnary.csv", FileAccess.READ)

	var dict_data: Dictionary = {}

	var line_index: int = -1
	var column_headers: Array
	while not file.eof_reached():
		line_index += 1
		var line: Array = file.get_csv_line(delimiter)

		if line_index == 0:
			column_headers = line
		else:
			var entry: Dictionary = {}
			for column_index in column_headers.size():
				var value = line[column_index] as String

				# Detect bools.
				if value is String:
					var value_lower: String = value.to_lower()
					if value_lower == "true":
						value = true
					elif value_lower == "false":
						value = false

				entry[column_headers[column_index]]	= value
				if column_headers[column_index] == id_column:
					dict_data[entry[id_column]] = entry

	return dict_data

func _play_line(lineName : AUDIO_LINE):
	lastLineSpoken.stop()
	
	var lineNameStr = AUDIO_LINE.keys()[lineName]
	var subtitledAudioStream = load("res://modules/narration/Audio/"+lineNameStr+".tres")
	if subtitledAudioStream != null:
		narratorStreamPlayer.stream = subtitledAudioStream.Audio
		narratorSubtitleLabel.text = subtitledAudioStream.SubtitleText
	else:
		var audioStream = load("res://modules/narration/Audio/AudioSource/"+lineNameStr+".wav")
		narratorStreamPlayer.stream = audioStream
		print(subtitles[lineNameStr]["subtitle"])
		narratorSubtitleLabel.text = subtitles[lineNameStr]["subtitle"]
	narratorStreamPlayer.play()
	
	lastLineSpoken.start()

func _on_game_state_kill():
		_play_line(AUDIO_LINE.Everyday)
		
func _on_game_state_metamorph(curse_nature : String):
	if(curse_nature == "Ww"):
		_play_line(AUDIO_LINE.narration_ww_intro)


func _on_audio_stream_player_finished():
	narratorSubtitleLabel.text = ""



func _on_last_line_spoken_timeout():
	_on_game_state_kill()
