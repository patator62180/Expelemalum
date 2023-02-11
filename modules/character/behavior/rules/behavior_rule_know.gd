extends "res://modules/character/behavior/rules/behavior_rule.gd"

@export var KNOWING_POWER_RATE : float = 0.3
@export var KNOWING_INCREMENT_RATE : float = 0.01

@export var FORGETTING_POWER_RATE : float = 0.3
@export var FORGETTING_INCREMENT_RATE : float = 0.01

func update_memory(delta : float, visible_characters : Array):
	super.update_memory(delta, visible_characters)
	# compute updating rule
	var character : Node2D = get_node(CHARACTER_PATH)
	for other_character in visible_characters:
		other_character = other_character as Node2D
		var direction_to_other_character : Vector2 = other_character.global_position - character.global_position
		var distance_to_other_character : float = direction_to_other_character.length()
		direction_to_other_character /= distance_to_other_character
		if distance_to_other_character > 0.0:
			character.memory[other_character]["know"] += (KNOWING_INCREMENT_RATE + pow(character.memory[other_character]["know"], KNOWING_POWER_RATE)) * (character.RADIUS_VISION / distance_to_other_character) * delta
	for other_character in character.memory:
		if not other_character in visible_characters:
			other_character = other_character as Node2D
			character.memory[other_character]["know"] -= (FORGETTING_INCREMENT_RATE + pow(character.memory[other_character]["know"] * character.memory[other_character]["love"], FORGETTING_POWER_RATE)) * delta
			if character.memory[other_character]["know"] <= 0.0:
				character.memory.erase(other_character)
				
