extends Label


# Called when the node enters the scene tree for the first time.



func _on_game_loop_game_won():
	text = "YOU WIN"


func _on_game_loop_game_lost():
	text = "YOU LOSE"
