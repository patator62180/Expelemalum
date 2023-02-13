extends "res://modules/character/peasants/peasant.gd"

const PERSONALITY_AGRESSIVITY : float = 10.0

func unmetamorphose():
	if not has_metamorphosed:
		$AnimRoot/Sprite2D.texture = preload("res://modules/character/peasants/assets/lumberjack_after_metamorphosis.svg")
	# unmetamorphose
	super.unmetamorphose()

# werewolf

func _choose_moving_direction_metamorphosed():
	moving_direction = Vector2.ZERO
	for character in visible_characters:
		character = character as Node2D
		var direction_to_character : Vector2 = character.global_position - global_position
		var distance_to_character : float = direction_to_character.length()
		direction_to_character /= distance_to_character
		if distance_to_character > 0.0:
			moving_direction += PERSONALITY_AGRESSIVITY * (1.0 / (2.1 + memory[character]["love"])) * direction_to_character / distance_to_character
	for boundary_exit in boundary_exits:
		var direction_to_boundary_exit : Vector2 = boundary_exit["position"] - global_position
		var distance_to_boundary_exit : float = direction_to_boundary_exit.length()
		direction_to_boundary_exit /= distance_to_boundary_exit
		if distance_to_boundary_exit > 0.0:
			moving_direction -= PERSONALITY_BOUNDARY_FEAR * boundary_exit["know"] * direction_to_boundary_exit / distance_to_boundary_exit
	moving_direction = moving_direction.normalized()

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
	$Area2DBody/CollisionShape2D.shape.radius = 12
	SPEED *= 1.5
	$AnimationPlayerMove.speed_scale *= 1.5
	if not has_metamorphosed:
		var axe_node : Node2D = preload("res://modules/character/peasants/droppables/axe.tscn").instantiate()
		axe_node.position = position
		axe_node.position.y -= 1
		get_parent().add_child(axe_node)

func _on_unmetamorphosed_sprite_changed():
	$Area2DBody/CollisionShape2D.shape.radius = 8
	SPEED /= 1.5
	$AnimationPlayerMove.speed_scale /= 1.5

func _on_animation_die_red():
	if has_metamorphosed:
		$AnimRoot/Sprite2D.texture = load("res://modules/character/peasants/assets/dead_lumberjack_after_metamorphosis.svg")
	else:
		$AnimRoot/Sprite2D.texture = load("res://modules/character/peasants/assets/dead_lumberjack.svg")
	$AnimRoot/Sprite2D.rotation = 0.5 * PI
