extends "res://modules/character/peasants/peasant.gd"

# werewolf

func _on_character_got_at_close_range_metamorphosed(character : Node2D):
	kill(character)

func _on_timer_metamorphose_timeout():
	$Area2DBody/CollisionShape2D.shape.radius = 12
	SPEED *= 1.65
	super._on_timer_metamorphose_timeout()

func _on_timer_unmetamorphose_timeout():
	$Area2DBody/CollisionShape2D.shape.radius = 8
	SPEED /= 1.65
	super._on_timer_unmetamorphose_timeout()
