extends Node

signal updatedKill
signal updatedTransformation(transformation)

#Basic state tracking
var PeasantKillCount : int = 0 #todo : update
var CurrentPeasantCount : int = 8 #todo : link init  + update

var ExorcistKillCount : int = 0 #todo : update
var RemainingExorcistsCount : int =  4 #todo : link init  + update

var SwipeCount : int = 0 #depreciated - to delete ?

var IsCurseAlive : bool = true

#use get_updated_swipeEvents to get it updated
var SwipeEvents : Array = [] #updated with _on_swipe func, to link
const SwipeMemory : int = 20 #number of seconds to remember Events




# FONCTION POUR LIEN AVEC LINTERFACE DEBUG UNIQUEMENT

func _on_transf_debug():
	_on_metamorph("Ww")
######################################################




func _on_swipe():
	SwipeEvents.append(Time.get_ticks_msec()/1000)

func get_updated_swipeEvents() -> Array:
	var currentDate : float = Time.get_ticks_msec()/1000
	if (SwipeEvents.size() > 0) :
		while(GameState.SwipeEvents[0] < currentDate - SwipeMemory) :
			GameState.SwipeEvents.remove_at(0)
	return SwipeEvents
	
func _on_kill():
	PeasantKillCount += 1
	emit_signal("updatedKill")


func _on_metamorph(curse_nature : String):
	emit_signal("updatedTransformation",curse_nature)

