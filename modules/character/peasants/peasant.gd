extends "res://modules/character/character.gd"

var is_metamorphosed : bool = false

# interface

func metamorphose():
	is_metamorphosed = true
	for area in $Area2DCloseRange.get_overlapping_areas():
		var character : Node2D = area.get_parent()
		if character != self:
			_on_character_got_at_close_range_metamorphosed(character)

func unmetamorphose():
	is_metamorphosed = false

# internal

func _choose_moving_direction():
	if is_metamorphosed:
		_choose_moving_direction_metamorphosed()
	else:
		super._choose_moving_direction()

func _choose_moving_direction_metamorphosed():
	pass # TO BE OVERLOADED

func _on_character_got_at_close_range(character : Node2D):
	if is_metamorphosed:
		_on_character_got_at_close_range_metamorphosed(character)
	else:
		super._on_character_got_at_close_range(character)

func _on_character_got_at_close_range_metamorphosed(character : Node2D):
	pass # TO BE OVERLOADED
