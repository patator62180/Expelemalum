extends "res://modules/character/behavior/memory/memory_rule.gd"

@export var SUPECTING_DISTANCE_FUNC : Curve
@export var SUSPECTING_SUSPICION_FUNC : Curve
@export var FORGETTING_SUSPICION_FUNC : Curve

const TIME : float = 0.4
const TEMPERATURE : float = 0.01

func _process(delta : float):
	# compute updating rule
	var behavior : Node = get_behavior()
	var character : Node2D = behavior.get_character()
	for other_character in behavior.memory:
		if (other_character in character.visible_characters) and ("is_metamorphosed" in other_character) and (other_character.is_metamorphosed):
			other_character = other_character as Node2D
			var distance_to_other_character : float = (other_character.global_position - character.global_position).length()
			var x_distance : float = distance_to_other_character / character.RADIUS_VISION
			var x_suspicion : float = behavior.memory[other_character]["suspicion"]
			if distance_to_other_character > 0.0:
				behavior.memory[other_character]["suspicion"] += SUSPECTING_SUSPICION_FUNC.sample_baked(x_suspicion) * SUPECTING_DISTANCE_FUNC.sample_baked(x_distance) * delta / TIME
		else:
			var x_suspicion : float = behavior.memory[other_character]["suspicion"]
			behavior.memory[other_character]["suspicion"] -= FORGETTING_SUSPICION_FUNC.sample_baked(x_suspicion) * delta / TIME
		# temperature and clamp
		behavior.memory[other_character]["suspicion"] += TEMPERATURE * delta / TIME * randf_range(0.0, 1.0)
		behavior.memory[other_character]["suspicion"] = clamp(behavior.memory[other_character]["suspicion"], 0.0, 1.0)
