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


#indicators : they need to be updated before use
var CurseActivity : float = 0.0 #de 0 à 1
var CurseEvilness : float = 0.5 #de 0 à 1
var CurrentDifficulty : float = CurrentExorcistCount / (CurrentExorcistCount + CurrentPeasantCount)#
var GameProgress : float = 0 #de 0 à 1

# FONCTION POUR LIEN AVEC LINTERFACE DEBUG UNIQUEMENT

func _on_transf_debug():
	_on_metamorph("Ww")
######################################################

func update_indicators():
	CurseEvilness = PeasantKillCount / (PeasantKillCount + ExorcistKillCount)
	CurrentDifficulty = CurrentExorcistCount / (CurrentExorcistCount + CurrentPeasantCount)
	
	var currentDate : float = Time.get_ticks_msec()/1000
	
	while(SwipeEvents[0] < currentDate - 20) :
		SwipeEvents.remove_at(0)
	
	CurseActivity = SwipeEvents.size()
	


func _on_swipe():
	SwipeEvents.append(Time.get_ticks_msec()/1000)
	

func _on_kill():
	PeasantKillCount += 1
	emit_signal("updatedKill")


func _on_metamorph(curse_nature : String):

	SwipeCount += 1
	emit_signal("updatedTransformation",curse_nature)

