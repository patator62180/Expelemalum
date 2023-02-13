extends Node2D

func _process(_delta):
	var total_weight : float = 0.0
	global_position = Vector2.ZERO
	for character in get_tree().get_nodes_in_group("character"):
		if character != null and not character.is_queued_for_deletion() and character.is_inside_tree():
			global_position += character.global_position
			total_weight += 1.0
	global_position /= total_weight
