extends "res://modules/character/behavior/memory/memory_rule.gd"

@export var KNOWING_DISTANCE_FUNC : Curve
@export var KNOWING_KNOW_FUNC : Curve
@export var FORGETTING_KNOW_FUNC : Curve

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
			var x_know : float = behavior.memory[other_character]["know"]
			if distance_to_other_character > 0.0:
				behavior.memory[other_character]["know"] += KNOWING_KNOW_FUNC.sample_baked(x_know) * KNOWING_DISTANCE_FUNC.sample_baked(x_distance) * delta / TIME
		else:
			character = character as Node2D
			var x_know : float = behavior.memory[other_character]["know"]
			behavior.memory[other_character]["know"] -= FORGETTING_KNOW_FUNC.sample_baked(x_know) * delta / TIME
		# temperature and clamp
		behavior.memory[other_character]["know"] += TEMPERATURE * delta / TIME * randf_range(-1.0, 1.0)
		behavior.memory[other_character]["know"] = clamp(behavior.memory[other_character]["know"], 0.0, 1.0)
				
