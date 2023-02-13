extends "res://modules/character/character_ui.gd"

func _on_character_killing(victim : Node2D):
	super._on_character_killing(victim)
#	$Fire.show()
#	$Fire/AnimationPlayer.play("scratch")

func _on_animation_die_red():
	var character : Node2D = get_character()
	$AnimRoot/Sprite2D.texture = load("res://modules/character/exorcists/assets/dead_exorcist.svg")
	$AnimRoot/Sprite2D.rotation = 0.5 * PI
