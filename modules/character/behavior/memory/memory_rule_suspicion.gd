extends "res://modules/character/behavior/rules/behavior_rule.gd"

@export var SUPECTING_DISTANCE_FUNC : Curve
@export var SUSPECTING_SUSPICION_FUNC : Curve
@export var FORGETTING_SUSPICION_FUNC : Curve

const TIME : float = 0.4
const TEMPERATURE : float = 0.01

func update_memory(delta : float, visible_characters : Array):
	super.update_memory(delta, visible_characters)
	# compute updating rule
	var character : Node2D = get_node(CHARACTER_PATH)
	for other_character in character.memory:
		if (other_character in visible_characters) and ("is_metamorphosed" in other_character) and (other_character.is_metamorphosed):
			other_character = other_character as Node2D
			var distance_to_other_character : float = (other_character.global_position - character.global_position).length()
			var x_distance : float = distance_to_other_character / character.RADIUS_VISION
			var x_suspicion : float = character.memory[other_character]["suspicion"]
			if distance_to_other_character > 0.0:
				character.memory[other_character]["suspicion"] += SUSPECTING_SUSPICION_FUNC.sample_baked(x_suspicion) * SUPECTING_DISTANCE_FUNC.sample_baked(x_distance) * delta / TIME
		else:
			character = character as Node2D
			var x_suspicion : float = character.memory[other_character]["suspicion"]
			character.memory[other_character]["suspicion"] -= FORGETTING_SUSPICION_FUNC.sample_baked(x_suspicion) * delta / TIME
		# temperature and clamp
		character.memory[other_character]["suspicion"] += TEMPERATURE * delta / TIME * randf_range(0.0, 1.0)
		character.memory[other_character]["suspicion"] = clamp(character.memory[other_character]["suspicion"], 0.0, 1.0)
