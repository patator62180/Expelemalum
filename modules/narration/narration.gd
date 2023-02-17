extends Control

const subtitle_speed : float = 1.5

@onready
var lastLineSpoken : Timer = $LastLineSpoken
@onready
var narratorSubtitleLabel : Label = get_node("Scroll/Label")

@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
const audio_source : String = "res://modules/narration/audio/audio_narration_dictionnary.csv"

@onready
var scrollAnimationPlayer : AnimationPlayer = get_node("ScrollAnimationPlayer")
@onready
var subtitleAnimationPlayer : AnimationPlayer = get_node("SubtitleAnimationPlayer")


var prompt_dict : Dictionary
var queued_prompts : Array
enum AUDIO_LINE {narration_trigger_gameLaunch_2, narration_trigger_default_defeat, narration_trigger_default_victory, narration_trigger_gameLaunch_1, narration_trigger_firstKill_peasant, narration_trigger_manaLack, narration_trigger_firstKill_exorcist, narration_trigger_ww_intro}

#See initiate indicators for structure
var indicators : Dictionary
#Each indicator value varies from -1 to 1. 0 is considered neutral 
enum INDICATORS {curseActivity, curseEvilness, currentDifficulty, gameProgress, filler}
enum PLAYTYPES {highIndicator, lowIndicator, noIndication, victoryLowIndicator, defeatLowIndicator, victoryHighIndicator, defeatHighIndicator}

const play_style_default = "Balanced"
const play_style_default_threshold = 1.4
#if all indicators' absolute value is under the filler threshold, 
# a filling prompt will be played.
const filler_threshold : float = 0.2
const activity_threshold : float = 2.0 #mean duration of a swipe to get the max indicator of activity


#INIT
###########################################################################

func _ready():
	
	# Connecting signals
	GameState.updated_kill_count.connect(_on_game_state_kill)
	GameState.updated_metamorphose_count.connect(_on_game_state_metamorphose)
	GameState.updated_game_phase.connect(_on_game_change)
	
	# Init
	prompt_dict = parse_csv_database(audio_source)
	initiate_indicators(true)
		
#	var choice = randi_range(0,1)
#	if choice == 1 :
#	_play_line_direct(AUDIO_LINE.narration_trigger_gameLaunch_1)
#	else :
#		_play_line_direct(AUDIO_LINE.narration_trigger_gameLaunch_2)
	play_situation_line(INDICATORS.filler, PLAYTYPES.noIndication)
	
	$MonitorLabel.text = ""

func initiate_indicators(complete_reset : bool = false) :
	
#	if complete_reset :
		#Make empty dictionnary
	indicators = {}
	for indicator in INDICATORS :
		# [indicator value, indicator id, playtype dictionnary containing prompts]
		indicators[INDICATORS[indicator]] = [0.0, INDICATORS[indicator], {}]
		
		for playType in PLAYTYPES :
			indicators[INDICATORS[indicator]][2][PLAYTYPES[playType]] = {
				"remaining_prompts" : 0,
				"asked_prompts" : 0,
				"prompts_array" : [[]]
				}
			
	#fill it with prompt_dict computed values
	for prompt in prompt_dict :
		var prompt_array = prompt_dict[prompt]
		var prompts_array = []
		
		var indic = prompt_array["onIndicator"]
		var playtyp = prompt_array["playType"]
		
		if (indic != null and indic >= 0) and (playtyp != null and indic >= 0) :
			register_asked_prompt(indic, playtyp, -1)
			var studied_array = indicators[indic][2][playtyp]["prompts_array"]
			
			if prompt_array["playOrderPriority"] > studied_array.size() :
				studied_array.resize(prompt_array["playOrderPriority"])
			if studied_array[prompt_array["playOrderPriority"]-1] == null :
				studied_array[prompt_array["playOrderPriority"]-1] = []
			studied_array[prompt_array["playOrderPriority"]-1].append(prompt)
	
	#Set the filler threshold
	indicators[INDICATORS.filler][0] = filler_threshold

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
					if value == "" :
						value = -1
					elif toComputeIdentifier in column_headers[column_index] :
						
#						assert(value != "","the file contains a blanck cell on a computed column : " + audio_source)
						
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


#NARRATION TRACKING 
############################################################################

func set_monitor(prefix : String = "", reset : bool = true, suffix : String = "") :
	
	if reset :
		var monitor : String = ""
		for i in indicators :
			monitor += str(INDICATORS.keys()[i]) + " val: " + str(indicators[i][0]) +" prompts : "
			for t in PLAYTYPES :
				monitor += str(get_indicators_remaining_prompts(i,PLAYTYPES[t]))
				monitor += "-"
				monitor += str(get_indicators_asked_prompts(i,PLAYTYPES[t]))
				monitor += "|"
			monitor += "\n"
		$MonitorLabel.text = prefix + "\n" + monitor + suffix
	else :
		$MonitorLabel.text = prefix + "\n" + $MonitorLabel.text + "\n" + suffix

func play_situation_line(
	indicator : INDICATORS,
	playType : PLAYTYPES,
	prompt_id : int = -1 #if -1 the func takes the highest priority at random
	) -> String :
	
	set_monitor("play line", false,"chosen situation :" + INDICATORS.keys()[indicator] + 	" - " + PLAYTYPES.keys()[playType] + "\n")

	var prompt_str : String
	var enough_prompt_remaining : bool
	
	if get_indicators_remaining_prompts(indicator, playType) > 0 :
		var prompts_array : Array = indicators[indicator][2][playType]["prompts_array"]
		
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
		
	register_asked_prompt(indicator,playType)
	
	return prompt_str

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
				error = (play_situation_line(studied_array[1],PLAYTYPES.highIndicator) == null)
				prompt_found = true
				
			else :
				register_asked_prompt(studied_array[1],PLAYTYPES.highIndicator)
		else :
			if studied_array[2][PLAYTYPES.lowIndicator]["remaining_prompts"] > 0 :
				error = (play_situation_line(studied_array[1],PLAYTYPES.lowIndicator) == null)
				prompt_found = true
	
			else :
				register_asked_prompt(studied_array[1],PLAYTYPES.lowIndicator)
				
		iterator += 1

	return prompt_found and not(error)


func play_best_ending_by_indicator(game_won : bool):
	
	var indicators_values = indicators.values()
	indicators_values.sort_custom(
		func(a,b): 
			return max(a[2][PLAYTYPES.highIndicator]["asked_prompts"],a[2][PLAYTYPES.lowIndicator]["asked_prompts"]) > max(b[2][PLAYTYPES.highIndicator]["asked_prompts"],b[2][PLAYTYPES.lowIndicator]["asked_prompts"]) 
	)
	var selected_indic = indicators_values[0]
	var selected_prompt_str : String
	
	if selected_indic[2][PLAYTYPES.highIndicator]["asked_prompts"] > play_style_default_threshold * selected_indic[2][PLAYTYPES.lowIndicator]["asked_prompts"] :
		# High indicator !
		if game_won :
			selected_prompt_str = play_situation_line(selected_indic[1],PLAYTYPES.victoryHighIndicator)
		else :
			selected_prompt_str = play_situation_line(selected_indic[1],PLAYTYPES.defeatHighIndicator)
	elif selected_indic[2][PLAYTYPES.lowIndicator]["asked_prompts"] > play_style_default_threshold * selected_indic[2][PLAYTYPES.highIndicator]["asked_prompts"] :
		# Low indicator !
		if game_won :
			selected_prompt_str = play_situation_line(selected_indic[1],PLAYTYPES.victoryLowIndicator)
		else :
			selected_prompt_str = play_situation_line(selected_indic[1],PLAYTYPES.victoryLowIndicator)
	
	if selected_prompt_str == null or selected_prompt_str == "" :
		set_monitor("Default ending prompt")
		if game_won :
			selected_prompt_str = play_situation_line(INDICATORS.filler, PLAYTYPES.victoryHighIndicator)
		else :
			selected_prompt_str = play_situation_line(INDICATORS.filler, PLAYTYPES.defeatHighIndicator)
	
	GameState.set_player_narration_state(prompt_dict[selected_prompt_str]["specialDisplay"])


func update_play_style():
	var indicator_instance_count : int = 0
	var instance_count_array : Array = []
	
	for i in INDICATORS :
		for p in PLAYTYPES :
			get_indicators_asked_prompts(INDICATORS[i], PLAYTYPES[p])
			

func update_indicators():
	# EVILNESS
	if ((GameState.get_total_kill_count()) == 0) :
		indicators[INDICATORS.curseEvilness][0] = 0.0
	else :
		indicators[INDICATORS.curseEvilness][0] = 2.0*(GameState.peasant_kill_count as float / (GameState.get_total_kill_count() as float)) - 1.0
	
	#DIFFICULTY
	indicators[INDICATORS.currentDifficulty][0] = 2.0*(GameState.remaining_exorcists_count as float / (GameState.remaining_exorcists_count as float + GameState.remaining_peasant_count as float)) - 1.0 #can be zero if world not init
	
	#GAME PROGRESS
	indicators[INDICATORS.gameProgress][0] = 2.0*(GameState.exorcist_kill_count as float / (GameState.exorcist_kill_count as float + GameState.remaining_exorcists_count as float)) - 1.0 #can be zero if world not init
	
	#ACTIVITY
	var number_of_swipes_done = GameState.get_updated_curse_events().size()
	indicators[INDICATORS.curseActivity][0] = 2.0 *(activity_threshold * number_of_swipes_done as float / GameState.curse_memory_duration as float) - 1.0
	
	GameState.set_player_narration_state("yolo")
	
	#debug
	set_monitor("update indicator")

func register_asked_prompt(
	indicator : INDICATORS,
	playtype : PLAYTYPES,
	delta : int = 1) :
	
	var studied_dict = indicators[indicator][2][playtype]
	
	if (delta > 0) : #if a prompt is asked
		
		#consume what is available to consume
		studied_dict["remaining_prompts"] = max (0 , studied_dict["remaining_prompts"] - delta)
		
		#register the asking
		studied_dict["asked_prompts"] += delta
		
	else : #if a prompt is aded
		studied_dict["remaining_prompts"] -= delta
	
func get_indicators_remaining_prompts(
	indicator : INDICATORS,
	playtype : PLAYTYPES
	) -> int :
			
	return indicators[indicator][2][playtype]["remaining_prompts"]

func get_indicators_asked_prompts(
	indicator : INDICATORS,
	playtype : PLAYTYPES
	) -> int :
		
	return indicators[indicator][2][playtype]["asked_prompts"]

# PLAYER MANAGEMENT
############################################################################

func _play_line_str(lineNameStr : String) :	
	if narratorStreamPlayer.playing :
		queued_prompts.append(lineNameStr)
		#idea : intégrer un priority accessible par le dico
		# 1 = priorité faible : will not be queued up
		# 2 = will be queued up
		# 3 = will be played next (can discard or pop current queue)
	else :
		var audioStream = load("res://modules/narration/audio/audio_source/"+lineNameStr+".mp3")
		narratorStreamPlayer.stream = audioStream
		narratorSubtitleLabel.text = prompt_dict[lineNameStr]["subtitle"]
		$MonitorLabel.text += "last clip: " + str(lineNameStr) + "\n"
	
		narratorStreamPlayer.play()
		subtitleAnimationPlayer.play("SubtitleReveal",-1, subtitle_speed/audioStream.get_length())
		scrollAnimationPlayer.play("ScrollIn")

func _play_line_direct(lineName : AUDIO_LINE) :
	_play_line_str(AUDIO_LINE.keys()[lineName])

func _on_audio_stream_player_finished():
	narratorStreamPlayer.stop()
	scrollAnimationPlayer.play_backwards("ScrollIn")
	
	if queued_prompts.size() > 0 :
		await get_tree().create_timer(1.0).timeout
		_play_line_str(queued_prompts.pop_front())
	if GameState.current_game_phase == GameState.GAME_PHASE.Gameplay :
		lastLineSpoken.start()

#EVENT MANAGEMENT
############################################################################

func _on_game_state_kill(killer : Node2D, victim : Node2D):
	
	if not(killer.character_type == killer.CHARACTER_TYPE.Exorcist) and GameState.get_total_kill_count() == 1:
		match victim.character_type :
			victim.CHARACTER_TYPE.Exorcist: 
					lastLineSpoken.stop()
					_play_line_direct(AUDIO_LINE.narration_trigger_firstKill_exorcist)
			victim.CHARACTER_TYPE.Lumberjack :
					lastLineSpoken.stop()
					_play_line_direct(AUDIO_LINE.narration_trigger_firstKill_peasant)

func _on_game_state_metamorphose(character : Node2D):
	if character.character_type == character.CHARACTER_TYPE.Lumberjack and GameState.metamorphose_count == 1:
		lastLineSpoken.stop()
		_play_line_direct(AUDIO_LINE.narration_trigger_ww_intro)

func _on_last_line_spoken_timeout():
	lastLineSpoken.stop()
	play_best_line_by_indicator()

func _on_game_change(old) :
	match GameState.current_game_phase :
		GameState.GAME_PHASE.Intro :
			pass
		GameState.GAME_PHASE.Gameplay :
			initiate_indicators()
			lastLineSpoken.start()
		GameState.GAME_PHASE.Outro :
			lastLineSpoken.stop()
			queued_prompts.clear()
			play_best_ending_by_indicator(GameState.game_won)

