extends "res://modules/character/character_ui.gd"

const POINT_SUSPICION_THRESHOLD : float = 0.2
@onready var pointer : Node2D = get_node("Pointer")

const pointer_speed : float = 4.0 #pixel/second
const pointer_offset : float = 20.0 #pixel
const pointer_alpha_time : float = 0.25

var fire : Node2D = null

func _process(delta : float):
	# super._process(delta) # non existent in character_ui.gd
	var character : Node2D = get_character()
	var character_behavior : Node = character.get_node("Behavior")
	# update pointer
	var suspicious_character : Node2D = _get_suspicious_character()
	if suspicious_character:
		pointer.global_position += (suspicious_character.global_position - (suspicious_character.global_position - character.global_position).normalized() * pointer_offset - pointer.global_position) * delta * pointer_speed
		pointer.look_at(suspicious_character.global_position)
		pointer.modulate.a += (1.0 - pointer.modulate.a) * delta / pointer_alpha_time
		if character_behavior.memory[suspicious_character]["suspicion"] > character.SUPICION_THRESHOLD_TO_KILL:
			if not $Info/Exclamation.visible:
				$Info/Exclamation.show()
			if $Info/Interrogation.visible:
				$Info/Exclamation.hide()
		else:
			if $Info/Exclamation.visible:
				$Info/Exclamation.hide()
			if not $Info/Interrogation.visible:
				$Info/Exclamation.show()
	else:
		pointer.global_position += (global_position + character.moving_direction * pointer_offset - pointer.global_position) * delta * pointer_speed
		pointer.global_rotation = character.moving_direction.angle()
		pointer.modulate.a += (0.0 - pointer.modulate.a) * delta / pointer_alpha_time
	pointer.modulate.a = clamp(pointer.modulate.a, 0.0, 1.0)
	$CurvedLines.modulate.a = pointer.modulate.a
	$Info.global_position = pointer.global_position + Vector2.UP * 10.0
	$Info.modulate.a = pointer.modulate.a
	# update line
	$CurvedLines/Line2D.points[0] = (character.global_position - global_position) + (pointer.global_position - character.global_position).normalized() * pointer_offset
	$CurvedLines/Line2D.points[$CurvedLines/Line2D.points.size()-1] = pointer.global_position - global_position
	# killing
	if character.is_killing:
		fire.global_position = character.victim.get_node("CharacterUI/AnimRoot").global_position

func _get_suspicious_character() -> Node2D:
	var character : Node2D = get_character()
	var character_behavior : Node = character.get_node("Behavior")
	var suspicous_character : Node2D = null
	var max_suspicion_value : float = 0.0
	for other_character in character.visible_characters:
		if other_character and ((not other_character.is_dying) or (not other_character.is_dead)):
			if other_character in character_behavior.memory and"suspicion" in character_behavior.memory[other_character]:
				if character_behavior.memory[other_character]["suspicion"] > POINT_SUSPICION_THRESHOLD:
					if character_behavior.memory[other_character]["suspicion"] > max_suspicion_value:
						suspicous_character = other_character
						max_suspicion_value = character_behavior.memory[other_character]["suspicion"]
	return suspicous_character

func _on_character_killing(victim : Node2D):
	super._on_character_killing(victim)
	fire = preload("res://modules/character/exorcists/droppables/fire.tscn").instantiate()
	get_character().get_parent().add_child(fire)
	fire.global_position = victim.get_node("CharacterUI/AnimRoot").global_position
	fire.global_position.y += 1

func _on_animation_die_red_specific():
	var character : Node2D = get_character()
	$AnimRoot/Sprite2D.texture = preload("res://modules/character/exorcists/assets/dead_exorcist.svg")
	$AnimRoot/Sprite2D.rotation = 0.5 * PI
