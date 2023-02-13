extends Control

var prompt_dict : Dictionary

#Structure of indicators :
# { INDICATORS.XX: [
#		value,           #index 0,  the value of the indicator
#		INDICATORS.XX,   
#		{ PLAYTYPES.XX:
#			{remaining_prompts : value
#			prompts_array : [[]]  #by priority
#			}         
#		},
#		]
#	}
		
var indicators : Dictionary

@onready
var lastLineSpoken : Timer = $LastLineSpoken
@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready
var narratorSubtitleLabel : Label = get_node("Label")

enum AUDIO_LINE {narration_timer_activity_high, narration_timer_activity_low, narration_timer_difficulty_high, narration_timer_difficulty_low, narration_timer_evilness_high, narration_timer_evilness_low, narration_timer_filler_1, narration_timer_filler_2, narration_timer_filler_3, narration_timer_progress_high, narration_timer_progress_low, narration_trigger_fewKills_exorcist, narration_trigger_fewKills_peasant, narration_trigger_firstKill_exorcist, narration_trigger_firstKill_peasant, narration_trigger_gameLaunch_1, narration_trigger_gameLaunch_2, narration_trigger_manaLack, narration_trigger_ww_intro}


#Each one varies from -1 to 1. 0 is considered average gameState
enum INDICATORS {curseActivity, curseEvilness, currentDifficulty, gameProgress, filler}

enum PLAYTYPES {highIndicator, lowIndicator, noIndication}


#INIT
###########################################################################

func _ready():
	
	# Connecting signals
	GameState.updatedKill.connect(_on_game_state_kill)
	GameState.updatedTransformation.connect(_on_game_state_metamorph)
	
#	var expression = Expression.new()
#	expression.parse("INDICATORS.curseEvilness")
#	var result = expression.execute()
#	print(result)  
	
	
	# Init
	prompt_dict = parse_csv_database("res://modules/narration/Audio/Audio - narrationDictionnary.csv")
	initiate_indicators() #with every indicator to 0 
	indicators[INDICATORS.filler][0] = 0.2 #setting indicator value
	
	# Début de la narration :
#	lastLineSpoken.start() # Optionnel si play_line après
	_play_line(AUDIO_LINE.narration_trigger_gameLaunch_1)

func initiate_indicators() :
	
	#Make empty dictionnary
	indicators = {}
	for indicator in INDICATORS :
		indicators[INDICATORS[indicator]] = [0.0, INDICATORS[indicator], {}]
		
		for playType in PLAYTYPES :
			indicators[INDICATORS[indicator]][2][PLAYTYPES[playType]] = {
				"remaining_prompts" : 0,
				"prompts_array" : [[]]
				}
			
			
	
	#fill it with prompt_dict computed values
	for prompt in prompt_dict :
		var prompt_array = prompt_dict[prompt]
		var prompts_array = []
		
		var indic = prompt_array["onIndicator"]
		var playtyp = prompt_array["playType"]
		
		if (indic != null) and (playtyp != null) :
			change_indicators_remaining_prompts(indic, playtyp, 1)
			var studied_array = indicators[indic][2][playtyp]["prompts_array"]
			
			if prompt_array["playOrderPriority"] > studied_array.size() :
				studied_array.resize(prompt_array["playOrderPriority"])
			if studied_array[prompt_array["playOrderPriority"]-1] == null :
				studied_array[prompt_array["playOrderPriority"]-1] = []
			studied_array[prompt_array["playOrderPriority"]-1].append(prompt)

func parse_csv_database(
	filename : String,
	id_column: String = "id",
	delimiter: String = ",",
	toComputeIdentifier : String = "computed"
) -> Dictionary:
	var file = FileAccess.open(filename, FileAccess.READ)

	var dict_data: Dictionary = {}

	var line_index: int = -1
	var column_headers: Array
	
	var trimmed_headers: Array 
	
	while not file.eof_reached():
		line_index += 1
		var line: Array = file.get_csv_line(delimiter)

		if line_index == 0:
			column_headers = line
			trimmed_headers = line.duplicate()
		else:
			var entry: Dictionary = {}
			for column_index in column_headers.size():
				var value = line[column_index] as String

				if value is String :
					if toComputeIdentifier in column_headers[column_index] :
						var expression = Expression.new()
						expression.parse(value)
						value = expression.execute([], self)
						
						var trimmed_header : String = trimmed_headers[column_index]
						trimmed_header = trimmed_header.trim_prefix(toComputeIdentifier)
						trimmed_header = trimmed_header[0].to_lower() + trimmed_header.substr(1,-1)
						trimmed_headers[column_index] = trimmed_header
				# Detect bools.
					else :
						var value_lower: String = value.to_lower()
						if value_lower == "true":
							value = true
						elif value_lower == "false":
							value = false
				
				
				
				entry[trimmed_headers[column_index]]	= value
				if column_headers[column_index] == id_column:
					dict_data[entry[id_column]] = entry

	return dict_data


#NARRATION TRACKING & AUDIO
############################################################################

func play_situation_line(
	indicator : INDICATORS,
	playType : PLAYTYPES,
	prompt_id : int = -1 #if -1 the func takes the highest priority at random
	) -> bool :
	
	var enough_prompt_remaining : bool
	
	if get_indicators_remaining_prompts(indicator, playType) > 0 :
		var prompts_array : Array = indicators[indicator][2][playType]["prompts_array"]
		var prompt_str : String
		
		if prompts_array[0].size() == 1 :
			prompt_str = prompts_array[0][0]
			prompts_array.remove_at(0)
		else :
			prompt_str = prompts_array[0].pick_random()
			prompts_array.erase(prompt_str)
			
		_play_line_str(prompt_str)
		enough_prompt_remaining = true
		
	else :
		enough_prompt_remaining = false
		
	change_indicators_remaining_prompts(indicator,playType,-1)
	
	return enough_prompt_remaining

func play_best_line_by_indicator() -> bool:
	
	update_indicators()
	
	var indicators_values = indicators.values()
	indicators_values.sort_custom(func(a,b): return abs(a[0]) > abs(b[0]) )
	
	var prompt_found : bool = false
	var error : bool = false
	var iterator : int = 0
	var studied_array : Array
#	[value, INDICATOR, {PLAYTYPES, prompt_remaining_count}]
	
	while (not(prompt_found or iterator >= indicators_values.size())) : # et fin du tableau pas trouvée 
		
		studied_array = indicators_values[iterator] 
		
		if (studied_array[0] > 0) :
			if studied_array[2][PLAYTYPES.highIndicator]["remaining_prompts"] > 0 :
				error = not(play_situation_line(studied_array[1],PLAYTYPES.highIndicator))
				prompt_found = true
				print("high found")
			else :
				change_indicators_remaining_prompts(studied_array[1],PLAYTYPES.highIndicator,-1)
		else :
			if studied_array[2][PLAYTYPES.lowIndicator]["remaining_prompts"] > 0 :
				error = not(play_situation_line(studied_array[1],PLAYTYPES.lowIndicator))
				prompt_found = true
				print("low found")
			else :
				change_indicators_remaining_prompts(studied_array[1],PLAYTYPES.lowIndicator,-1)
				
		iterator += 1
	print("ERROR ? ",error)
	return prompt_found and not(error)

func update_indicators():
	
	# EVILNESS
	if ((GameState.PeasantKillCount + GameState.ExorcistKillCount) == 0) :
		indicators[INDICATORS.curseEvilness][0] = 0.0
	else :
		indicators[INDICATORS.curseEvilness][0] = 2*(GameState.PeasantKillCount / (GameState.PeasantKillCount + GameState.ExorcistKillCount)) - 1.0
	
	#DIFFICULTY
	indicators[INDICATORS.currentDifficulty][0] = 2*(GameState.CurrentExorcistCount / (GameState.CurrentExorcistCount + GameState.CurrentPeasantCount)) - 1.0
	
	#GAME PROGRESS
	indicators[INDICATORS.gameProgress][0] = 2*(GameState.ExorcistKillCount / (GameState.ExorcistKillCount + GameState.CurrentExorcistCount)) - 1.0
	
	#ACTIVITY
	var currentDate : float = Time.get_ticks_msec()/1000
	if (GameState.SwipeEvents.size() == 0) :
		indicators[INDICATORS.curseActivity][0] = -1.0
	else :
		while(GameState.SwipeEvents[0] < currentDate - 20) :
			GameState.SwipeEvents.remove_at(0)
		indicators[INDICATORS.curseActivity][0] = 2 *(GameState.SwipeEvents.size() / 20) - 1.0

func change_indicators_remaining_prompts(
	indicator : INDICATORS,
	playtype : PLAYTYPES,
	delta : int) :
			
	indicators[indicator][2][playtype]["remaining_prompts"] += delta
	
func get_indicators_remaining_prompts(
	indicator : INDICATORS,
	playtype : PLAYTYPES
	) -> int :
			
	return indicators[indicator][2][playtype]["remaining_prompts"]

func _play_line_str(lineNameStr : String) :
	
	var audioStream = load("res://modules/narration/Audio/AudioSource/"+lineNameStr+".mp3")
	narratorStreamPlayer.stream = audioStream
	narratorSubtitleLabel.text = prompt_dict[lineNameStr]["subtitle"]
	narratorStreamPlayer.play()
	
	lastLineSpoken.start()

func _play_line_direct(lineName : AUDIO_LINE) :
	_play_line_str(AUDIO_LINE.keys()[lineName])

func _play_line(lineName : AUDIO_LINE):
	lastLineSpoken.stop()
	
	if narratorStreamPlayer.playing :
		await get_tree().create_timer(5.0).timeout
		_play_line(lineName)
	else :
		_play_line_direct(lineName)


#EVENT MANAGEMENT
############################################################################

func _on_game_state_kill():
	lastLineSpoken.stop()
	_play_line(AUDIO_LINE.narration_trigger_firstKill_exorcist)
		
func _on_game_state_metamorph(curse_nature : String):
	lastLineSpoken.stop()
	if(curse_nature == "Ww"):
		_play_line(AUDIO_LINE.narration_trigger_ww_intro)

func _on_audio_stream_player_finished():
	narratorStreamPlayer.stop()
#	lastLineSpoken.stop()
	pass

func _on_last_line_spoken_timeout():
	lastLineSpoken.stop()
	
	print("Get Ready !")
	if not(play_best_line_by_indicator()) :
		print("it did not happen... :(")
	else :
		print("supposed to work ;)")
	
