extends "res://modules/character/character.gd"

const PERSONALITY_SUSPECTIVE : float = 10.0

const SUPICION_THRESHOLD_TO_KILL : float = 0.8

# internal

func _choose_moving_direction():
	moving_direction = Vector2.ZERO
	for character in visible_characters:
		character = character as Node2D
		var direction_to_character : Vector2 = character.global_position - global_position
		var distance_to_character : float = direction_to_character.length()
		direction_to_character /= distance_to_character
		if distance_to_character > 0.0:
			moving_direction += PERSONALITY_SUSPECTIVE * memory[character]["suspicion"] * direction_to_character / distance_to_character
			moving_direction += PERSONALITY_SOCIABILITY * memory[character]["love"] * direction_to_character / distance_to_character
			moving_direction -= PERSONALITY_CURIOSITY * memory[character]["know"] * direction_to_character / distance_to_character
	moving_direction = moving_direction.normalized()

func _on_character_got_at_close_range(character : Node2D):
	if memory[character]["suspicion"] > SUPICION_THRESHOLD_TO_KILL:
		character.die()
	else:
		super._on_character_got_at_close_range(character)
	
