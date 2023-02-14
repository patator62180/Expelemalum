extends "res://modules/character/peasants/peasant_character_ui.gd"

func _process(delta : float):
	var character : Node2D = get_character()
	if character.is_killing and character.victim != null and not character.victim.is_queued_for_deletion():
		$Scratch.global_position = character.victim.global_position

func _on_character_killing(victim : Node2D):
	super._on_character_killing(victim)
	$Scratch.show()
	$Scratch/AnimationPlayer.play("scratch")

func _on_character_metamorphosed():
	$AnimationPlayerMove.speed_scale *= 1.5
	super._on_character_metamorphosed()

func _on_character_unmetamorphosing():
	if not get_character().has_metamorphosed:
		$AnimRoot/Sprite2D.texture = preload("res://modules/character/peasants/assets/lumberjack_after_metamorphosis.svg")
	super._on_character_unmetamorphosing()

func _on_character_unmetamorphosed():
	$AnimationPlayerMove.speed_scale /= 1.5
	super._on_character_unmetamorphosed()

func _on_metamorphosed_sprite_changed():
	var character : Node2D = get_character()
	if not character.has_metamorphosed:
		var axe_node : Node2D = preload("res://modules/character/peasants/droppables/axe.tscn").instantiate()
		character.get_parent().add_child(axe_node)
		axe_node.global_position = global_position
		axe_node.position.y -= 1

func _on_animation_die_red_specific():
	var character : Node2D = get_character()
	if character.has_metamorphosed:
		$AnimRoot/Sprite2D.texture = load("res://modules/character/peasants/assets/dead_lumberjack_after_metamorphosis.svg")
	else:
		$AnimRoot/Sprite2D.texture = load("res://modules/character/peasants/assets/dead_lumberjack.svg")
	$AnimRoot/Sprite2D.rotation = 0.5 * PI
