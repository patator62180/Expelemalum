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

func kill(victim : Node2D):
	if not is_metamorphosing:
		super.kill(victim)

func metamorphose():
	if not is_dead and not is_dying:
		is_metamorphosing = true
		$TimerMetamorphose.start()
		emit_signal("metamorphosing")

func _on_timer_metamorphose_timeout():
	is_metamorphosing = false
	is_metamorphosed = true
	for area in $Area2DCloseRange.get_overlapping_areas():
		var character : Node2D = area.get_parent()
		if character != self:
			_on_character_got_at_close_range(character)
	$TimerMetamorphosisDuration.start()
	emit_signal("metamorphosed")

func unmetamorphose():
	if not is_dead and not is_dying:
		is_metamorphosing = true
		$TimerUnmetamorphose.start()
		emit_signal("unmetamorphosing")

func _on_timer_unmetamorphose_timeout():
	is_metamorphosing = false
	is_metamorphosed = false
	if not has_metamorphosed:
		has_metamorphosed = true
	emit_signal("unmetamorphosed")

func die(killer_character : Node2D):
	super.die(killer_character)
	$TimerMetamorphose.stop()
	$TimerUnmetamorphose.stop()
	$TimerMetamorphosisDuration.stop()

# internal

func _on_character_got_at_close_range(character : Node2D):
	if is_metamorphosed:
		_on_character_got_at_close_range_metamorphosed(character)
	else:
		super._on_character_got_at_close_range(character)

func _on_character_got_at_close_range_metamorphosed(character : Node2D):
	assert(false, "this method should be overloaded")

func _on_timer_metamorphosis_duration_timeout():
	unmetamorphose()
