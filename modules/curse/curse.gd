extends Node2D

# editor var

@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath

@onready var curse_area : Area2D = get_node("Area2D")
@onready var curse_range : float = get_node("Area2D/CollisionShape2D").shape.radius
@onready var line : Line2D = get_node("CurvedLine")
@onready var arrow : Sprite2D = get_node("ArrowDown")
@onready var skullPathFollow : Node2D = get_node("Path2D/PathFollow2D")

#const var
const target_angle_epsilon = 0.1* TAU
const line_circle_radius = 10 #pixel
const arrowSpeed = 10 #pixel/second
const arrowOffset = Vector2(0,-30) #pixel
const skullSpeed = 10 #pixel/second

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
	if cursable_character != null:
		if cursable_character.is_queued_for_deletion():
			cursable_character = null
		else:
			var sprite : Sprite2D = character.get_node("CharacterUI/AnimRoot/Sprite2D")
			sprite.modulate = Color.hex(0xa770c2ff)

func _freeCursableCharacter():
	if cursable_character != null:
		if cursable_character.is_queued_for_deletion():
			cursable_character = null
		else:
			var sprite : Sprite2D = cursable_character.get_node("CharacterUI/AnimRoot/Sprite2D")
			sprite.modulate = Color.WHITE

func _process(delta : float):
	_update_Cursable_Character()
	_update_line(delta)
	_update_skull(delta)

func _update_Cursable_Character():
	#if cursable go out of range, unhighlight
	if cursable_character != null and not curse_area.overlaps_area(cursable_character.get_node("Area2DBody")):
		_freeCursableCharacter()

	var inputVector : Vector2 = (get_global_mouse_position()-global_position)
	if inputVector != Vector2.ZERO:
		inputVector = inputVector.normalized()
	
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
	if event.is_action_released("metamorphose") and not cursed_character.is_metamorphosed and not cursed_character.is_metamorphosing:
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

func _highlightCursableCharacters(area_array : Array, enable : bool):
	for area in area_array:
		if area != null:			
			var character : Node2D = area.get_parent()
			if not enable or character != cursed_character:
				var sprite : Sprite2D = character.get_node("CharacterUI/AnimRoot/Sprite2D")
				sprite.modulate = Color.hex(0xa770c2ff) if enable else Color.WHITE

func _get_input_vector() -> Vector2:
	return (get_global_mouse_position()-global_position).normalized()

func _update_line(delta : float):
	arrow.global_position += (_get_arrow_target() - arrow.global_position) * delta * arrowSpeed
	arrow.look_at(cursable_character.global_position if cursable_character else 2*arrow.global_position - skullPathFollow.global_position)
	
	line.points[0] = skullPathFollow.position
	line.points[line.points.size()-1] = arrow.global_position - global_position

func _get_arrow_target():
	if cursable_character:
		var sprite : Sprite2D = cursable_character.get_node("CharacterUI/AnimRoot/Sprite2D")
		return sprite.global_position + arrowOffset
	else:
		return _get_input_vector()*line_circle_radius + skullPathFollow.global_position

func _update_skull(delta : float):
	global_position += (cursed_character.global_position - global_position) * delta * skullSpeed
