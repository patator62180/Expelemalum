extends "res://modules/character/character.gd"

@export var SUPICION_THRESHOLD_TO_KILL : float

func _on_character_got_at_close_range(character : Node2D):
	if character in $Behavior.memory and $Behavior.memory[character]["suspicion"] > SUPICION_THRESHOLD_TO_KILL:
		if not (("is_metamorphosed" in character) and (character.is_metamorphosed)):
			kill(character)
	else:
		super._on_character_got_at_close_range(character)
