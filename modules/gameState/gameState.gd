extends Node

signal updatedKill
signal updatedTransformation(transformation)

var KillCount : int = 0
var SwipeCount : int = 0

# FONCTION POUR LIEN AVEC LINTERFACE DEBUG UNIQUEMENT

func _on_transf_debug():
	_on_metamorph("Ww")

####################################################

func _on_kill():
	KillCount += 1
	emit_signal("updatedKill")


func _on_metamorph(curse_nature : String):

	SwipeCount += 1
	emit_signal("updatedTransformation",curse_nature)

