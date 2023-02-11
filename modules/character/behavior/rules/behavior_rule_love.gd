extends "res://modules/character/behavior/rules/behavior_rule.gd"

@export var PERSONAL_SPACE : float = 20.0

@export var LOVING_POWER_RATE : float = 0.5
@export var LOVING_INCREMENT_RATE : float = 0.01

@export var HATING_POWER_RATE : float = 1.5
@export var HATING_INCREMENT_RATE : float = -0.01

@export var FORGETTING_POWER_RATE : float = 0.25
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
			if distance_to_other_character > PERSONAL_SPACE:
				character.memory[other_character]["love"] += (LOVING_INCREMENT_RATE + pow(character.memory[other_character]["love"], LOVING_POWER_RATE)) * ((character.RADIUS_VISION - PERSONAL_SPACE) / (distance_to_other_character - PERSONAL_SPACE)) * delta
			else:
				character.memory[other_character]["love"] += (HATING_INCREMENT_RATE + pow(character.memory[other_character]["love"], HATING_POWER_RATE)) * ((distance_to_other_character - PERSONAL_SPACE) / PERSONAL_SPACE) * delta
	for other_character in character.memory:
		if not other_character in visible_characters:
			character = character as Node2D
			character.memory[other_character]["love"] -= sign(character.memory[other_character]["love"]) * (FORGETTING_INCREMENT_RATE + pow(character.memory[other_character]["know"] * abs(character.memory[other_character]["love"]), FORGETTING_POWER_RATE)) * delta
