extends "res://modules/character/character_ui.gd"

func _ready():
	super._ready()
	# get character
	var character : Node2D = get_character()
	# connect
	character.metamorphosing.connect(_on_character_metamorphosing)
	character.unmetamorphosing.connect(_on_character_unmetamorphosing)
	character.metamorphosed.connect(_on_character_metamorphosed)
	character.unmetamorphosed.connect(_on_character_unmetamorphosed)

func _on_character_metamorphosing():
	$AnimationPlayerMove.stop()
	$AnimationPlayerMetamorphose.play("metamorphose")
	$AudioStreamPlayer2DMetamorphose.play()

func _on_character_unmetamorphosing():
	$AnimationPlayerMove.stop()
	$AnimationPlayerMetamorphose.play("unmetamorphose")
	$AudioStreamPlayer2DMetamorphose.play()

func _on_character_metamorphosed():
	$AnimationPlayerMove.play("moving")

func _on_character_unmetamorphosed():
	$AnimationPlayerMove.play("moving")

# signal

func _on_metamorphosed_sprite_changed():
	pass

func _on_unmetamorphosed_sprite_changed():
	pass
