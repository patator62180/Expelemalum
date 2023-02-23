extends Node2D

#const var
const TARGET_ANGLE_EPSILON = 0.1* TAU
const SKULL_SPEED = 10 #pixel/second

const ANIM_IDLE = "Skull_Idle"
const ANIM_INTRO = "skull_intro"
const ANIM_OUTRO = "skull_outro"
# editor var
@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath

#ingame var
var _cursed_character : Node2D = null
var _cursable_character : Node2D = null
var _controller_enabled : bool = false

@onready var skull_sprite : Node2D = get_node("Path2D/PathFollow2D/Skull")

func enable_controller(enable : bool, play_anim : bool = true):
	_controller_enabled = enable
	if play_anim:
		if enable:
			$AnimationPlayerPointer.play("line_in") 
		else:
			$AnimationPlayerPointer.play_backwards("line_in")

func enable_controller(enable : bool, play_anim : bool = true):
	_controller_enabled = enable
	if play_anim:
		if enable:
			$AnimationPlayerPointer.play("line_in") 
		else:
			$AnimationPlayerPointer.play_backwards("line_in")

# built-in internal

func _ready():
	enable_controller(false, false)
	_curse(get_node(INITIALLY_CURSED_CHARACTER))
	tree_exiting.connect(_on_tree_exiting)
	$AnimationPlayerSkull.connect("animation_finished", _on_curse_animation_finished)
	$CurvedLines.origin = skull_sprite
	$CurvedLines.target = $Pointer

func _process(delta : float):
	if _controller_enabled:
		_update_cursable_character()
	_update_position(delta)

func _input(event : InputEvent):
	if _controller_enabled:
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
		_cursed_character.uncurse()
		_cursed_character.tree_exiting.disconnect(_on_cursed_character_dead)
	_cursed_character = character
	_cursed_character.tree_exiting.connect(_on_cursed_character_dead)
	_cursed_character.curse()
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
	
	$Pointer.target = _cursable_character

func _free_cursable_character():
	if _cursable_character != null:
		if _cursable_character.is_queued_for_deletion():
			_cursable_character = null
	$Pointer.target = null

func _update_cursable_character():
	#if cursable go out of range, unhighlight
	if _cursable_character != null and not _cursable_character.is_dead and not $CurseArea.overlaps_area(_cursable_character.get_node("Area2DBody")):
		_free_cursable_character()

	var inputVector : Vector2 = _get_input_vector()
	
	var overlapping_areas = $CurseArea.get_overlapping_areas()
	var cursable_candidates : Array = Array()
	for area in overlapping_areas:
		var character : Node2D = area.get_parent()
		if character != _cursed_character:
			var toCharacterVector : Vector2 = character.global_position - _cursed_character.global_position
			if abs(toCharacterVector.angle_to(inputVector)) < TARGET_ANGLE_EPSILON:
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
	var inputVector = (get_global_mouse_position()-skull_sprite.global_position)
	if inputVector == Vector2.ZERO:
		return inputVector
	return inputVector.normalized()

func _update_position(delta : float):
	if _cursed_character:
		global_position += (_cursed_character.global_position - global_position) * delta * SKULL_SPEED

func _on_curse_animation_finished(anim_name : StringName):
	if anim_name == ANIM_INTRO:
		enable_controller(true)
		$AnimationPlayerSkull.play(ANIM_IDLE)
	if anim_name == ANIM_OUTRO:
		queue_free()

func _on_cursed_character_dead():
	_cursed_character = null
	enable_controller(false)
	$AnimationPlayerSkull.play(ANIM_OUTRO)
