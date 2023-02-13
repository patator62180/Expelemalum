extends "res://modules/character/behavior/memory/memory_rule.gd"

@export var LOVING_DISTANCE_FUNC : Curve
@export var LOVING_LOVE_FUNC : Curve
@export var FORGETTING_LOVE_FUNC : Curve

const TIME : float = 1.0
const TEMPERATURE : float = 0.01

func _process(delta : float):
	# compute updating rule
	var behavior : Node = get_behavior()
	var character : Node2D = behavior.get_character()
	for other_character in behavior.memory:
		if other_character in character.visible_characters:
			other_character = other_character as Node2D
			var distance_to_other_character : float = (other_character.global_position - character.global_position).length()
			var x_distance : float = distance_to_other_character / character.RADIUS_VISION
			var x_love : float = (1.0 + behavior.memory[other_character]["love"]) / 2.0
			if distance_to_other_character > 0.0:
				behavior.memory[other_character]["love"] += LOVING_LOVE_FUNC.sample_baked(x_love) * LOVING_DISTANCE_FUNC.sample_baked(x_distance) * delta / TIME
		else:
			character = character as Node2D
			var x_love : float = abs(behavior.memory[other_character]["love"])
			behavior.memory[other_character]["love"] -= sign(behavior.memory[other_character]["love"]) * FORGETTING_LOVE_FUNC.sample_baked(x_love) * delta / TIME
		# temperature and clamp
		behavior.memory[other_character]["love"] += TEMPERATURE * delta / TIME * randf_range(-1.0, 1.0)
		behavior.memory[other_character]["love"] = clamp(behavior.memory[other_character]["love"], -1.0, 1.0)
