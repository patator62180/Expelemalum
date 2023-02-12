extends Control
@onready
var lastLineSpoken : Timer = $LastLineSpoken
@onready
var subtitles : Dictionary = parseSubtitles()
@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready
var narratorSubtitleLabel : Label = get_node("Label")
enum AUDIO_LINE {narration_ww_intro, narration_firstKill_exorcist, narration_firstKill_peasant, narration_fewKills_exorcist, narration_fewKills_peasant, narration_gameLaunch}

#indicators : they need to be updated before use
var CurseActivity : float = 0.0 #de 0 à 1
var CurseActivityPromptCount : int = 0
var CurseEvilness : float = 0.5 #de 0 à 1
var CurseEvilnessPromptCount : int = 0
var CurrentDifficulty : float = 0 #de 0 à 1
var DifficultyPromptCount : int = 0
var GameProgress : float = 0 #de 0 à 1
var GameProgressPromptCount : int = 0
enum INDICATORS {curseActivity, curseEvilness, currentDifficulty, gameProgress, filler}

func _ready():
	GameState.updatedKill.connect(_on_game_state_kill)
	GameState.updatedTransformation.connect(_on_game_state_metamorph)
	
	var subtitles : Dictionary = parseSubtitles()
	lastLineSpoken.start()
	_play_line(AUDIO_LINE.narration_gameLaunch)

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
	var audioStream = load("res://modules/narration/Audio/AudioSource/"+lineNameStr+".wav")
	narratorStreamPlayer.stream = audioStream
	#narratorSubtitleLabel.text = subtitles[lineNameStr]["subtitle"]
	narratorStreamPlayer.play()
	
	lastLineSpoken.start()

func _on_game_state_kill():
		_play_line(AUDIO_LINE.narration_firstKill_peasant)
		
func _on_game_state_metamorph(curse_nature : String):
	if(curse_nature == "Ww"):
		_play_line(AUDIO_LINE.narration_ww_intro)


func _on_audio_stream_player_finished():
	narratorSubtitleLabel.text = ""



func _on_last_line_spoken_timeout():
	update_indicators()
	var chosen_indicator = choose_indicator()
	
	match chosen_indicator[1] :
		
		INDICATORS.curseActivity:
			if chosen_indicator[0] > 0 :
				_play_line(AUDIO_LINE.narration_ww_intro)
			else :
				_play_line(AUDIO_LINE.narration_ww_intro)
				
		INDICATORS.curseEvilness:
			if chosen_indicator[0] > 0 :
				_play_line(AUDIO_LINE.narration_ww_intro)
			else :
				_play_line(AUDIO_LINE.narration_ww_intro)
				
		INDICATORS.currentDifficulty:
			if chosen_indicator[0] > 0 :
				_play_line(AUDIO_LINE.narration_ww_intro)
			else :
				_play_line(AUDIO_LINE.narration_ww_intro)
				
		INDICATORS.gameProgress:
			if chosen_indicator[0] > 0 :
				_play_line(AUDIO_LINE.narration_ww_intro)
			else :
				_play_line(AUDIO_LINE.narration_ww_intro)
				
		INDICATORS.filler:
			if chosen_indicator[0] > 0 :
				_play_line(AUDIO_LINE.narration_ww_intro)
			else :
				_play_line(AUDIO_LINE.narration_ww_intro)


func choose_indicator() -> Array :
	
	var indicators : Array = [[CurseActivity-0.5,INDICATORS.curseActivity],
		[CurseEvilness-0.5,INDICATORS.curseEvilness],
		[CurrentDifficulty-0.5, INDICATORS.currentDifficulty],
		[GameProgress-0.5, INDICATORS.gameProgress],
		[0.2, INDICATORS.filler]]
	
	indicators.sort_custom(func(a,b): return abs(a[0]) > abs(b[0]) )
	
	return indicators[0]

func update_indicators():
	CurseEvilness = GameState.PeasantKillCount / (GameState.PeasantKillCount + GameState.ExorcistKillCount)
	CurrentDifficulty = GameState.CurrentExorcistCount / (GameState.CurrentExorcistCount + GameState.CurrentPeasantCount)
	
	var currentDate : float = Time.get_ticks_msec()/1000
	
	while(GameState.SwipeEvents[0] < currentDate - 20) :
		GameState.SwipeEvents.remove_at(0)
	
	CurseActivity = GameState.SwipeEvents.size() / 20
