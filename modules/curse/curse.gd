extends Node2D

#Editor var

@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath
@onready var curse_area : Area2D = get_node("Area2D")
@onready var curse_range : float = get_node("Area2D/CollisionShape2D").shape.radius
@onready var line : Line2D = get_node("Line2D")

#const var
const target_angle_epsilon = 0.1* TAU
const line_circle_radius = 20

#ingame var
var cursed_character : Node2D = null
var cursable_character : Node2D = null

#Signal
signal curse
signal cantCurse

# internal

func _ready():
	_curse(get_node(INITIALLY_CURSED_CHARACTER))

func _curse(character : Node2D):
	if cursed_character != null:
		cursed_character.is_cursed = false
		cursed_character.tree_exiting.disconnect(queue_free)
	cursed_character = character
	cursed_character.tree_exiting.connect(queue_free)
	cursed_character.is_cursed = true
	_freeCursableCharacter()
	emit_signal("curse")

func _try_curse(character : Node2D):
	if character != null:
		_curse(character)
	else:
		emit_signal("cantCurse")

func _highlightCursableCharacter(character : Node2D):
	_freeCursableCharacter()
	cursable_character = character
	if cursable_character:
		var sprite : Sprite2D = character.get_node("AnimRoot/Sprite2D")
		sprite.modulate = Color.hex(0xa770c2ff)
		line.show()
		line.points[0] = _get_input_vector()*line_circle_radius
		line.points[line.points.size()-1] = cursable_character.global_position - global_position

func _freeCursableCharacter():
	if cursable_character == null:
		return
	var sprite : Sprite2D = cursable_character.get_node("AnimRoot/Sprite2D")
	sprite.modulate = Color.WHITE
	cursable_character = null
	line.hide()

func _process(delta : float):
	_update_Cursable_Character()
	global_position = cursed_character.global_position

func _update_Cursable_Character():
	#if cursable go out of range, unhighlight
	if cursable_character != null and not curse_area.overlaps_area(cursable_character.get_node("Area2DBody")):
		_freeCursableCharacter()

	var inputVector = (get_global_mouse_position()-global_position).normalized()
	
	var overlapping_areas = curse_area.get_overlapping_areas()
	var cursable_candidates : Array
	for area in overlapping_areas:
		var character : Node2D = area.get_parent()
		if character != cursed_character:
			var toCharacterVector : Vector2 = character.global_position - cursed_character.global_position
			if abs(toCharacterVector.angle_to(inputVector)) < target_angle_epsilon:
				cursable_candidates.append(character)
	
	_highlightCursableCharacter(_get_closest_character(cursable_candidates))

func _dist_to_cursable_character()-> float :
	if cursable_character == null:
		return INF
	return cursable_character.global_position.distance_to(cursed_character.global_position)

func _input(event : InputEvent):
	if event.is_action_released("curse"):
		_try_curse(cursable_character)

	if event.is_action_released("activate") and not cursed_character.is_metamorphosed:
		cursed_character.metamorphose()

func _on_tree_exiting():
	GameState.IsCurseAlive= false

func _get_closest_character(characters : Array) -> Node2D:
	var closest_character : Node2D = null
	var closest_character_distance : float = INF
	for character in characters:
		if character != cursed_character:
			var character_distance : float = (character.global_position - cursed_character.global_position).length()
			if character_distance < closest_character_distance:
				closest_character = character
				closest_character_distance = character_distance
	return closest_character

func _get_input_vector() -> Vector2:
	return (get_global_mouse_position()-global_position).normalized()
