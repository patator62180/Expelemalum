extends "res://modules/character/character.gd"

@export var SUPICION_THRESHOLD_TO_KILL : float

func _ready():
	super._ready()
	# GameState update
	GameState.remaining_exorcists_count += 1
	if not Engine.is_editor_hint():
		tree_exiting.connect(_on_tree_exiting_)

func _on_character_got_at_close_range(character : Node2D):
	if character in $Behavior.memory and $Behavior.memory[character]["suspicion"] > SUPICION_THRESHOLD_TO_KILL:
		if not (("is_metamorphosed" in character) and (character.is_metamorphosed)):
			kill(character)
	else:
		super._on_character_got_at_close_range(character)

func _on_tree_exiting_():
	GameState.remaining_exorcists_count -= 1
