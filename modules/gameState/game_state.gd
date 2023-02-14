extends Node

signal updated_kill_count(killer, victim)
signal updated_metamorphose_count(character)
signal updated_remaining_count
signal updated_game_phase(previous_phase, new_phase)

signal curse_killed

enum GAME_PHASE {Intro,Gameplay,Outro}
var current_game_phase : GAME_PHASE

# basic state tracking
var peasant_kill_count : int = 0
var remaining_peasant_count : int = 0
var exorcist_kill_count : int = 0
var remaining_exorcists_count : int = 0

var is_curse_alive : bool = true

var metamorphose_count : int = 0
var curse_events : Array = [] # updated with on_curse func, to link
const curse_memory_duration : float = 20.0 # number of seconds to remember Events

var player_narration_state : String = "Satanic"

func get_updated_curse_events() -> Array:
	var current_date : float = Time.get_ticks_msec()/1000.0
	while(not curse_events.is_empty() and GameState.curse_events[0] < current_date - curse_memory_duration) :
		curse_events.pop_front()
	return curse_events

# called somewhere else in the code
func start_game():
	remaining_exorcists_count = 0
	exorcist_kill_count = 0
	game_phase_update(GAME_PHASE.Gameplay)

func game_phase_update(new_phase : GAME_PHASE) : #TODO CONNECT
	emit_signal("updated_game_phase", current_game_phase, new_phase)
	current_game_phase = new_phase

func on_curse_killed():
	is_curse_alive = false
	emit_signal("curse_killed")

func on_curse(character : Node2D):
	curse_events.append(Time.get_ticks_msec()/1000.0)

func on_spawn(character : Node2D):
	match character.character_type:
		character.CHARACTER_TYPE.Exorcist:
			remaining_exorcists_count += 1
		_:
			remaining_peasant_count += 1
	emit_signal("updated_remaining_count")

func on_kill(killer : Node2D, victim : Node2D): # TODO call on kill
	match victim.character_type:
		victim.CHARACTER_TYPE.Exorcist:
			exorcist_kill_count += 1
			remaining_exorcists_count -= 1
		_:
			peasant_kill_count += 1
			remaining_peasant_count -= 1
	emit_signal("updated_kill_count", killer, victim)
	emit_signal("updated_remaining_count")

func on_metamorphose(character : Node2D): # TODO call on metamorphose
	metamorphose_count += 1
	emit_signal("updated_metamorphose_count", character)
	emit_signal("updated_remaining_count")


	

func _input(event : InputEvent):
	if event is InputEventKey:
		match event.keycode:
			KEY_K:
				emit_signal("curse_killed")
			KEY_J:
				remaining_exorcists_count = 0
				emit_signal("updated_remaining_count")
