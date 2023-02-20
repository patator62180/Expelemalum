extends Node

signal updated_kill_count(killer, victim)
signal updated_metamorphose_count(character)
signal updated_remaining_count
signal updated_game_phase(previous_phase)
signal curse_killed

enum GAME_PHASE {Intro,Gameplay,Outro}

const CURSE_MEMORY_DURATION : float = 20.0 # number of seconds to remember Events

var current_game_phase : GAME_PHASE = GAME_PHASE.Intro
var game_won : bool = true

# basic state tracking
var peasant_kill_count : int = 0
var remaining_peasant_count : int = 0
var exorcist_kill_count : int = 0
var remaining_exorcists_count : int = 0
var metamorphose_count : int = 0

var player_narration_state : String = "Quick Looser"

var _curse_events : Array = [] # updated with on_curse func, to link

# public
func start_gameplay():	
	GameState.game_phase_update(GameState.GAME_PHASE.Gameplay)

func reset_gamestate():
	remaining_exorcists_count = 0
	exorcist_kill_count = 0

func game_phase_update(new_phase : GAME_PHASE) :
	var previous_game_phase = current_game_phase
	current_game_phase = new_phase
	emit_signal("updated_game_phase", previous_game_phase)

func on_curse_killed():
	emit_signal("curse_killed")

func on_curse(_character : Node2D):
	_curse_events.append(Time.get_ticks_msec()/1000.0)

func on_spawn(character : Node2D):
	match character.character_type:
		character.CHARACTER_TYPE.Exorcist:
			remaining_exorcists_count += 1
		_:
			remaining_peasant_count += 1
	emit_signal("updated_remaining_count")

func on_kill(killer : Node2D, victim : Node2D):
	match victim.character_type:
		victim.CHARACTER_TYPE.Exorcist:
			exorcist_kill_count += 1
			remaining_exorcists_count -= 1
		_:
			peasant_kill_count += 1
			remaining_peasant_count -= 1
	emit_signal("updated_kill_count", killer, victim)
	emit_signal("updated_remaining_count")

func on_metamorphose(character : Node2D):
	metamorphose_count += 1
	emit_signal("updated_metamorphose_count", character)

func set_player_narration_state(new_state : String) :
	player_narration_state = new_state

func get_total_kill_count() -> int :
	return peasant_kill_count + exorcist_kill_count

func get_updated_curse_events() -> Array:
	var current_date : float = Time.get_ticks_msec()/1000.0
	while(not _curse_events.is_empty() and GameState._curse_events[0] < current_date - CURSE_MEMORY_DURATION) :
		_curse_events.pop_front()
	return _curse_events

#internal built_in

func _input(event : InputEvent):
	if OS.is_debug_build():
		if event is InputEventKey:
			match event.keycode:
				KEY_K:
					emit_signal("curse_killed")
				KEY_J:
					remaining_exorcists_count = 0
					emit_signal("updated_remaining_count")
