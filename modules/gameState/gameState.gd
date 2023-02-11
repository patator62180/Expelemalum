extends Node

signal TriggerIntroLine
signal TriggerIntroLineTooMuch

var IntroTriggerCount : int = 0

func _on_button_pressed():
	IntroTriggerCount += 1
	emit_signal("TriggerIntroLine")
	if(IntroTriggerCount == 5):
		emit_signal("TriggerIntroLineTooMuch")
