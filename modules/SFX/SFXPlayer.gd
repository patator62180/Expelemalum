extends AudioStreamPlayer

func _play(sfxName : String):
	var audioStream = load("res://modules/SFX/Audio/"+sfxName+".wav")
	stream = audioStream
	play()


func _on_curse_curse():
	_play("Curse") # Replace with function body.

func _on_peasant_metamorphosed():
	_play("Metamorph")

func _on_character_died():
	_play("Die")
