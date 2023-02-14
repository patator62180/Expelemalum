extends "res://modules/character/character_ui.gd"

func _on_character_killing(victim : Node2D):
	super._on_character_killing(victim)
	var fire : Node2D = preload("res://modules/character/exorcists/droppables/fire.tscn").instantiate()
	get_character().get_parent().add_child(fire)
	fire.global_position = victim.get_node("CharacterUI/AnimRoot").global_position
	fire.global_position.y += 1

func _on_animation_die_red_specific():
	var character : Node2D = get_character()
	$AnimRoot/Sprite2D.texture = preload("res://modules/character/exorcists/assets/dead_exorcist.svg")
	$AnimRoot/Sprite2D.rotation = 0.5 * PI
