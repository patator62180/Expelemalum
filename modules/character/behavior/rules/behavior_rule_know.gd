extends "res://modules/character/behavior/rules/behavior_rule.gd"

@export var KNOWING_DISTANCE_FUNC : Curve
@export var KNOWING_KNOW_FUNC : Curve
@export var FORGETTING_KNOW_FUNC : Curve

const TIME : float = 1.0
const TEMPERATURE : float = 0.01

func update_memory(delta : float, visible_characters : Array):
	super.update_memory(delta, visible_characters)
	# compute updating rule
	var character : Node2D = get_node(CHARACTER_PATH)
	for other_character in character.memory:
		if other_character in visible_characters:
			other_character = other_character as Node2D
			var distance_to_other_character : float = (other_character.global_position - character.global_position).length()
			var x_distance : float = distance_to_other_character / character.RADIUS_VISION
			var x_know : float = character.memory[other_character]["know"]
			if distance_to_other_character > 0.0:
				character.memory[other_character]["know"] += KNOWING_KNOW_FUNC.sample_baked(x_know) * KNOWING_DISTANCE_FUNC.sample_baked(x_distance) * delta / TIME
		else:
			character = character as Node2D
			var x_know : float = character.memory[other_character]["know"]
			character.memory[other_character]["know"] -= FORGETTING_KNOW_FUNC.sample_baked(x_know) * delta / TIME
		# temperature and clamp
		character.memory[other_character]["know"] += TEMPERATURE * delta / TIME * randf_range(-1.0, 1.0)
		character.memory[other_character]["know"] = clamp(character.memory[other_character]["know"], 0.0, 1.0)
				
