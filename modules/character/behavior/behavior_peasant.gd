extends "res://modules/character/behavior/behavior.gd"

func _ready():
	super._ready()
	# more
	var character : Node2D = get_character()
	character.metamorphosing.connect(_on_character_metamorphosing)
	character.metamorphosed.connect(_on_character_metamorphosed)
	character.unmetamorphosing.connect(_on_character_unmetamorphosing)
	character.unmetamorphosed.connect(_on_character_unmetamorphosed)

func _on_character_metamorphosing():
	$AnimationPlayerMove.stop()
	SPEED_FACTOR = 0.0

func _on_character_metamorphosed():
	$AnimationPlayerMove.play("move")

func _on_character_unmetamorphosing():
	$AnimationPlayerMove.stop()
	SPEED_FACTOR = 0.0

func _on_character_unmetamorphosed():
	$AnimationPlayerMove.play("move")

func _get_moving_direction():
	if get_character().is_metamorphosed:
		return _get_moving_direction_metamorphosed()
	else:
		return super._get_moving_direction()

func _get_moving_direction_metamorphosed():
	assert(false, "this method should be overloaded")
