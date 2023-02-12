extends AudioStreamPlayer

func _play(sfxName : String):
	var audioStream = load("res://modules/SFX/Audio/"+sfxName+".wav")
	stream = audioStream
	play()

func _on_curse_curse():
	_play("Curse") # Replace with function body.

func _on_peasant_metamorphosed():
	_play("Metamorph")
	GameState.ExorcistKillCount

func _on_curse_cant_curse():
	_play("CantCurse") # Replace with function body.

func _on_character_dying(dieType):
	match (dieType):
		DIE_TYPE.Exorcist:
			_play("DieExorcist")
		DIE_TYPE.Werewolf:
			_play("DieWerewolf")
