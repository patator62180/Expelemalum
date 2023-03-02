extends Node2D

#const var
const target_angle_epsilon = 0.1* TAU
const line_circle_radius = 30 #pixel
const pointerSpeed = 10 #pixel/second
const pointerOffset = Vector2(0,-30) #pixel
const skullSpeed = 10 #pixel/second

# editor var
@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath

#ingame var
var _cursed_character : Node2D = null
var _cursable_character : Node2D = null

@onready var line : Node2D = get_node("CurvedLines").get_child(0)
@onready var skullPathFollow : Node2D = get_node("Path2D/PathFollow2D")

# built-in internal

func _ready():
	_curse(get_node(INITIALLY_CURSED_CHARACTER))
	tree_exiting.connect(_on_tree_exiting)

func _process(delta : float):
	_update_cursable_character()
	_update_line(delta)
	_update_skull(delta)

func _input(event : InputEvent):
	if event.is_action_released("curse") and not $Area2DMouse.mouse_in:
		_try_curse(_cursable_character)
	if event.is_action_released("metamorphose") or event.is_action_released("curse") and $Area2DMouse.mouse_in:
		if not _cursed_character.is_metamorphosed and not _cursed_character.is_metamorphosing:
			GameState.on_metamorphose(_cursed_character)
			_cursed_character.metamorphose()
		else:
			$AnimationPlayerForbidden.play("forbidden")
			$Sfx/AudioStreamPlayerTransformForbidden.play()
			$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DLeft.hide()
			$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DRight.show()

func _on_tree_exiting():
	GameState.on_curse_killed()

# internal

func _curse(character : Node2D):
	if _cursed_character != null:
		_cursed_character.is_cursed = false
		_cursed_character.tree_exiting.disconnect(queue_free)
	_cursed_character = character
	_cursed_character.tree_exiting.connect(queue_free)
	_cursed_character.is_cursed = true
	_free_cursable_character()
	$Sfx/AudioStreamPlayer2DJump.play()

func _try_curse(character : Node2D):
	if character != null:
		GameState.on_curse(character)
		_curse(character)
	else:
		$AnimationPlayerForbidden.play("forbidden")
		$Sfx/AudioStreamPlayerJumpForbidden.play()
		$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DLeft.show()
		$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DRight.hide()

func _highlight_cursable_character(character : Node2D):
	_free_cursable_character()
	_cursable_character = character
	if _cursable_character != null:
		if _cursable_character.is_queued_for_deletion():
			_cursable_character = null

func _free_cursable_character():
	if _cursable_character != null:
		if _cursable_character.is_queued_for_deletion():
			_cursable_character = null

func _update_cursable_character():
	#if cursable go out of range, unhighlight
	if _cursable_character != null and not _cursable_character.is_dead and not $CurseArea.overlaps_area(_cursable_character.get_node("Area2DBody")):
		_free_cursable_character()

	var inputVector : Vector2 = (get_global_mouse_position() - global_position)
	if inputVector != Vector2.ZERO:
		inputVector = inputVector.normalized()
	
	var overlapping_areas = $CurseArea.get_overlapping_areas()
	var cursable_candidates : Array = Array()
	for area in overlapping_areas:
		var character : Node2D = area.get_parent()
		if character != _cursed_character:
			var toCharacterVector : Vector2 = character.global_position - _cursed_character.global_position
			if abs(toCharacterVector.angle_to(inputVector)) < target_angle_epsilon:
				cursable_candidates.append(character)
	
	_highlight_cursable_character(_get_closest_character(cursable_candidates))

func _dist_to_cursable_character()-> float :
	if _cursable_character == null:
		return INF
	return _cursable_character.global_position.distance_to(_cursed_character.global_position)

func _get_closest_character(characters : Array) -> Node2D:
	var closest_character : Node2D = null
	var closest_character_distance : float = INF
	for character in characters:
		if character != _cursed_character:
			var character_distance : float = (character.global_position - _cursed_character.global_position).length()
			if character_distance < closest_character_distance:
				closest_character = character
				closest_character_distance = character_distance
	return closest_character
	
func _get_input_vector() -> Vector2:
	return (get_global_mouse_position()-global_position).normalized()

func _update_line(delta : float):
	# update Pointer
	$Pointer.global_position += (_get_pointer_target() - $Pointer.global_position) * delta * pointerSpeed
	if _cursable_character:
		$Pointer.look_at(_cursable_character.global_position)
		if not $Pointer/HandOpen.visible:
			$Pointer/HandOpen.show()
		if $Pointer/HandPoint.visible:
			$Pointer/HandPoint.hide()
	else:
		$Pointer.look_at(2*$Pointer.global_position - skullPathFollow.global_position)
		if $Pointer/HandOpen.visible:
			$Pointer/HandOpen.hide()
		if not $Pointer/HandPoint.visible:
			$Pointer/HandPoint.show()
	# update line
	line.points[0] = skullPathFollow.position
	line.points[line.points.size()-1] = $Pointer.global_position - global_position + 6.0 * Vector2.LEFT.rotated($Pointer.rotation)

func _get_pointer_target():
	if _cursable_character and ((not _cursable_character.is_dying) or (not _cursable_character.is_dead)):
			var sprite : Sprite2D = _cursable_character.get_node("CharacterUI/AnimRoot/Sprite2D")
			return sprite.global_position + pointerOffset
	else:
		return _get_input_vector()*line_circle_radius + skullPathFollow.global_position

func _update_skull(delta : float):
	global_position += (_cursed_character.global_position - global_position) * delta * skullSpeed
