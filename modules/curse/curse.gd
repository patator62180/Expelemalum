extends Node2D

# Called when the node enters the scene tree for the first time.
func _input(event : InputEvent):
	if event is InputEventJoypadMotion:
		pass # TODO MANAGE JOYPAD
	elif event is InputEventAction:
			if event.pressed:
				match event.action:
					"up":
						pass
					"down":
						
