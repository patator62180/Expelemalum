extends Area2D

var mouse_in : bool = false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	mouse_in = true

func _on_mouse_exited():
	mouse_in = false
