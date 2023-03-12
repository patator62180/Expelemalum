extends Node2D

#const var
const TARGET_ANGLE_EPSILON : float = 0.1* TAU
const SKULL_SPEED : float = 10 #pixel/second

const ANIM_IDLE = "Skull_Idle"
const ANIM_INTRO = "skull_intro"
const ANIM_OUTRO = "skull_outro"
# editor var
@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath

#ingame var
var cursed_character : Node2D = null:
	get:
		return cursed_character
	set(character):
		if cursed_character != null:
			cursed_character.uncurse()
			cursed_character.tree_exiting.disconnect(_oncursed_character_dead)
		cursed_character = character
		if cursed_character != null:
			cursed_character.tree_exiting.connect(_oncursed_character_dead)
			cursed_character.curse()
			$Sfx/AudioStreamPlayer2DJump.play()		
			GameState.on_curse(character)
		cursable_character = null

var cursable_character : Node2D = null:
	get:
		return cursable_character
	set(character):
		cursable_character = character
		$Pointer.target = cursable_character

var _controller_enabled : bool = false

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
	cursed_character = get_node(INITIALLY_CURSED_CHARACTER)
	tree_exiting.connect(_on_tree_exiting)
	$AnimationPlayerSkull.connect("animation_finished", _on_curse_animation_finished)
	$CurvedLines.origin = $Path2D/PathFollow2D/Skull
	$CurvedLines.target = $Pointer

func _process(delta : float):
	if _controller_enabled:
		_update_cursable_character()
	_update_position(delta)

func _input(event : InputEvent):
	if _controller_enabled:
		if event.is_action_released("curse") and not $Area2DMouse.mouse_in:
			_try_curse(cursable_character)
		if event.is_action_released("metamorphose") or event.is_action_released("curse") and $Area2DMouse.mouse_in:
			if is_instance_valid(cursed_character) and not cursed_character.is_dying and not cursed_character.is_dead and not cursed_character.is_metamorphosed and not cursed_character.is_metamorphosing:
				GameState.on_metamorphose(cursed_character)
				cursed_character.metamorphose()
			else:
				$AnimationPlayerForbidden.play("forbidden")
				$Sfx/AudioStreamPlayerTransformForbidden.play()
				$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DLeft.hide()
				$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DRight.show()

func _on_tree_exiting():
	GameState.on_curse_killed()

# internal

func _try_curse(character : Node2D):
	if is_instance_valid(cursed_character) and not cursed_character.is_dying and not cursed_character.is_dead and is_instance_valid(character):
		cursed_character = character
	else:
		$AnimationPlayerForbidden.play("forbidden")
		$Sfx/AudioStreamPlayerJumpForbidden.play()
		$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DLeft.show()
		$Path2D/PathFollow2D/Skull/Sprite2DForbidden/Sprite2DRight.hide()

func _update_cursable_character():
	#if cursable go out of range, unhighlight
	if cursable_character != null and not cursable_character.is_queued_for_deletion() and not cursable_character.is_dead and not $CurseArea.overlaps_area(cursable_character.get_node("Area2DBody")):
		cursable_character = null

	var inputVector : Vector2 = _get_input_vector()
	
	var overlapping_areas = $CurseArea.get_overlapping_areas()
	var cursable_candidates : Array = Array()
	for area in overlapping_areas:
		var character : Node2D = area.get_parent()
		if character != cursed_character:
			var toCharacterVector : Vector2 = character.global_position - cursed_character.global_position
			if abs(toCharacterVector.angle_to(inputVector)) < TARGET_ANGLE_EPSILON:
				cursable_candidates.append(character)
	
	cursable_character = _get_closest_character(cursable_candidates)

func _dist_tocursable_character()-> float :
	if cursable_character == null:
		return INF
	return cursable_character.global_position.distance_to(cursed_character.global_position)

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
	var inputVector = (get_global_mouse_position()-$Path2D/PathFollow2D/Skull.global_position)
	if inputVector == Vector2.ZERO:
		return inputVector
	return inputVector.normalized()

func _update_position(delta : float):
	if cursed_character:
		global_position += (cursed_character.global_position - global_position) * delta * SKULL_SPEED

func _on_curse_animation_finished(anim_name : StringName):
	if anim_name == ANIM_INTRO:
		enable_controller(true)
		$AnimationPlayerSkull.play(ANIM_IDLE)
	if anim_name == ANIM_OUTRO:
		queue_free()

func _oncursed_character_dead():
	cursed_character = null
	enable_controller(false)
	$AnimationPlayerSkull.play(ANIM_OUTRO)
