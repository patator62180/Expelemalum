extends "res://modules/character/behavior/behavior.gd"

func _get_moving_direction():
	if get_character().is_metamorphosed:
		return _get_moving_direction_metamorphosed()
	else:
		return super._get_moving_direction()

func _get_moving_direction_metamorphosed():
	assert(false, "this method should be overloaded")
