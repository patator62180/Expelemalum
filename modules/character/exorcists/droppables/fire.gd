extends Node2D

signal done

func _on_fire_done():
	emit_signal("done")

func _ready():
	# build animation
	var tween : Tween = get_tree().create_tween()#.bind_node(self)
	tween.tween_property($Root, "modulate", Color.RED, 1)
	tween.tween_property($Root, "scale", Vector2.ZERO, 1)
	#tween.tween_callback(queue_free)
