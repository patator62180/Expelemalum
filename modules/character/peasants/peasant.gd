extends "res://modules/character/character.gd"

var is_metamorphosing : bool = false
var is_metamorphosed : bool = false
var has_metamorphosed : bool = false

signal metamorphosing
signal unmetamorphosing
signal metamorphosed
signal unmetamorphosed

signal cursed

# interface

func metamorphose():
	is_metamorphosing = true
	$AnimationPlayerMove.stop()
	SPEED_FACTOR = 0.0
	$TimerMetamorphose.start()
	emit_signal("metamorphosing")

func _on_timer_metamorphose_timeout():
	is_metamorphosing = false
	is_metamorphosed = true
	for area in $Area2DCloseRange.get_overlapping_areas():
		var character : Node2D = area.get_parent()
		if character != self:
			_on_character_got_at_close_range(character)
	$AnimationPlayerMove.play("move")
	emit_signal("metamorphosed")

func unmetamorphose():
	is_metamorphosing = true
	$AnimationPlayerMove.stop()
	SPEED_FACTOR = 0.0
	$TimerUnmetamorphose.start()
	emit_signal("unmetamorphosing")

func _on_timer_unmetamorphose_timeout():
	is_metamorphosing = false
	is_metamorphosed = false
	if not has_metamorphosed:
		has_metamorphosed = true
	$AnimationPlayerMove.play("move")
	emit_signal("unmetamorphosed")

func _on_character_got_at_close_range(character : Node2D):
	if is_metamorphosed:
		_on_character_got_at_close_range_metamorphosed(character)
	else:
		super._on_character_got_at_close_range(character)

func _on_character_got_at_close_range_metamorphosed(character : Node2D):
	assert(false, "this method should be overloaded")
