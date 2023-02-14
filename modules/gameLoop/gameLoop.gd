extends Node2D

signal game_lost
signal game_won

func _ready():
	GameState.curse_killed.connect(on_game_state_cursed_killed)
	GameState.updated_remaining_count.connect(on_game_state_updated_remaining_count)


func on_game_state_updated_remaining_count():
	if GameState.remaining_exorcists_count < 1:
		emit_signal("game_won")
	
func on_game_state_cursed_killed():
	emit_signal("game_lost")
