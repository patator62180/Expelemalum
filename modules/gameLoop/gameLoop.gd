extends Node2D

signal game_lost
signal game_won

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.remaining_exorcists_count == 0:
		_win()
	if GameState.is_curse_alive == false:
		_lose()


func _win():
	emit_signal("game_won")
	
func _lose():
	emit_signal("game_lost")
