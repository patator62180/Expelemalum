extends "res://modules/character/behavior/behavior.gd"

@export var PERSONALITY_SUSPECTIVE : float

func _get_moving_direction():
	# init
	var character : Node2D = get_character()
	var moving_direction : Vector2 = Vector2.ZERO
	# compute
	for other_character in character.visible_characters:
		if other_character != null and not other_character.is_queued_for_deletion() and not other_character.is_dying:
			other_character = other_character as Node2D
			var direction_to_other_character : Vector2 = other_character.global_position - character.global_position
			var distance_to_other_character : float = direction_to_other_character.length()
			direction_to_other_character /= distance_to_other_character
			if distance_to_other_character > 0.0:
				moving_direction += PERSONALITY_SUSPECTIVE * memory[other_character]["suspicion"] * direction_to_other_character / distance_to_other_character
				moving_direction += PERSONALITY_SOCIABILITY * memory[other_character]["love"] * direction_to_other_character / distance_to_other_character
				moving_direction -= PERSONALITY_CURIOSITY * memory[other_character]["know"] * direction_to_other_character / distance_to_other_character
				moving_direction -= PERSONALITY_COWARD * memory[other_character]["fear"] * direction_to_other_character / distance_to_other_character
	if moving_direction == Vector2.ZERO:
		moving_direction = curiosity_direction
	for boundary_exit in boundary_exits:
		var direction_to_boundary_exit : Vector2 = boundary_exit["position"] - character.global_position
		var distance_to_boundary_exit : float = direction_to_boundary_exit.length()
		direction_to_boundary_exit /= distance_to_boundary_exit
		if distance_to_boundary_exit > 0.0:
			moving_direction -= PERSONALITY_BOUNDARY_FEAR * boundary_exit["know"] * direction_to_boundary_exit / distance_to_boundary_exit
	return moving_direction.normalized()
