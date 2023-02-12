extends Node

signal updatedKill
signal updatedTransformation(transformation)

#Basic state tracking
var PeasantKillCount : int = 0
var ExorcistKillCount : int = 0
var CurrentExorcistCount : int = 4
var CurrentPeasantCount : int = 8
var SwipeCount : int = 0
var RemainingExorcistsCount : int = 0
var IsCurseAlive : bool = true
var SwipeEvents : Array = []




# FONCTION POUR LIEN AVEC LINTERFACE DEBUG UNIQUEMENT

func _on_transf_debug():
	_on_metamorph("Ww")
######################################################




func _on_swipe():
	SwipeEvents.append(Time.get_ticks_msec()/1000)
	

func _on_kill():
	PeasantKillCount += 1
	emit_signal("updatedKill")


func _on_metamorph(curse_nature : String):

	SwipeCount += 1
	emit_signal("updatedTransformation",curse_nature)

