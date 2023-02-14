extends Node2D

signal done

func _on_scratch_done():
	emit_signal("done")
