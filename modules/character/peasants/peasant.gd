extends "res://modules/character/character.gd"

var is_metamorphosing : bool = false
var is_metamorphosed : bool = false
var has_metamorphosed : bool = false

signal metamorphosed
signal unmetamorphosed

signal cursed

# interface

func metamorphose():
	is_metamorphosing = true
	$AnimationPlayerMove.stop()
	ANIMATION_SPEED_FACTOR = 0.0
	$AnimationPlayerMetamorphose.play("metamorphose")

func unmetamorphose():
	is_metamorphosing = true
	$AnimationPlayerMove.stop()
	ANIMATION_SPEED_FACTOR = 0.0
	$AnimationPlayerMetamorphose.play("unmetamorphose")

# internal

func _metamorphose():
	is_metamorphosing = false
	is_metamorphosed = true
	for area in $Area2DCloseRange.get_overlapping_areas():
		var character : Node2D = area.get_parent()
		if character != self:
			_on_character_got_at_close_range(character)
	$AnimationPlayerMove.play("Moving")
	emit_signal("metamorphosed")

func _unmetamorphose():
	is_metamorphosing = false
	is_metamorphosed = false
	if not has_metamorphosed:
		has_metamorphosed = true
	$AnimationPlayerMove.play("Moving")
	emit_signal("unmetamorphosed")

func _ready():
	super._ready()
	metamorphosed.connect(SFXPlayer._on_peasant_metamorphosed)

func _choose_moving_direction():
	if is_metamorphosed:
		_choose_moving_direction_metamorphosed()
	else:
		super._choose_moving_direction()

func _choose_moving_direction_metamorphosed():
	pass # TO BE OVERLOADED

func _on_character_got_at_close_range(character : Node2D):
	if is_metamorphosed:
		_on_character_got_at_close_range_metamorphosed(character)
	else:
		super._on_character_got_at_close_range(character)

func _on_character_got_at_close_range_metamorphosed(character : Node2D):
	pass # TO BE OVERLOADED

# signal

func _on_animation_player_metamorphose_animation_finished(anim_name : String):
	if anim_name == "metamorphose":
		_metamorphose()
	elif anim_name == "unmetamorphose":
		_unmetamorphose()
	else:
		assert(false, "the animation name should be metamorphosed or unmetamorphosed")

func _on_metamorphosed_sprite_changed():
	pass

func _on_unmetamorphosed_sprite_changed():
	pass
