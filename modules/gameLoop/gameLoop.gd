extends Node2D

signal game_lost
signal game_won

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.RemainingExorcistsCount == 0:
		_win()
	if GameState.IsCurseAlive == false:
		_lose()


func _win():
	emit_signal("game_won")
	
func _lose():
	emit_signal("game_lost")
