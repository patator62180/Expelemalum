extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$ButtonKill.pressed.connect(GameState.on_kill)
	$ButtonTransfWw.pressed.connect(GameState._on_transf_debug)
