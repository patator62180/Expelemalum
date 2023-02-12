@tool
extends EditorScript

func _run():
	for scroll in get_scene().get_node("Background").get_children():
		scroll = scroll as Node2D
		scroll.modulate.v = randf_range(0.8, 1.0)
		scroll.rotation += 0.1 * TAU * randf_range(-1.0, 1.0)
