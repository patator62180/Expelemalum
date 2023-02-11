extends Node

signal updated

var KillCount : int = 0
var RemainingExorcistsCount : int = 0
var IsCurseAlive : bool = true

func _on_kill():
	KillCount += 1
	emit_signal("updated")
