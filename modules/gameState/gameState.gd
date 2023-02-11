extends Node

signal updated

var KillCount : int = 0

func _on_kill():
	KillCount += 1
	emit_signal("updated")
