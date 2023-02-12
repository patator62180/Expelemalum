extends "res://modules/character/peasants/peasant.gd"

func unmetamorphose():
	if not has_metamorphosed:
		$AnimRoot/Sprite2D.texture = preload("res://modules/character/peasants/assets/lumberjack_after_metamorphosis.svg")
	# unmetamorphose
	super.unmetamorphose()

# werewolf

func _choose_moving_direction_metamorphosed():
	moving_direction = (_get_less_loved_character(visible_characters).global_position - global_position).normalized()

func _on_character_got_at_close_range_metamorphosed(character : Node2D):
	character.die(DIE_TYPE.Werewolf)
	unmetamorphose()

# util

func _get_less_loved_character(character_array : Array) -> Node2D:
	var less_loved_character : Node2D = null
	var less_loved_character_love : float = INF
	for character in character_array:
		if memory[character]["love"] < less_loved_character_love:
			less_loved_character = character
			less_loved_character_love = memory[character]["love"]
	return less_loved_character

#func _get_closest_character(character_array : Array) -> Node2D:
#	var closest_character : Node2D = null
#	var closest_character_distance : float = INF
#	for character in character_array:
#		var character_distance : float = (character.global_position - global_position).length()
#		if character_distance < closest_character_distance:
#			closest_character = character
#			closest_character_distance = character_distance
#	return closest_character

func _on_metamorphosed_sprite_changed():
	if not has_metamorphosed:
		var axe_node : Node2D = preload("res://modules/character/peasants/droppables/axe.tscn").instantiate()
		axe_node.position = position
		axe_node.position.y -= 1
		get_parent().add_child(axe_node)
