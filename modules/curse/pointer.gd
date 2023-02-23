extends Node2D

const SPEED = 10 #pixel/second
const OFFSET = Vector2(0,-30) #pixel
const CIRCLE_RADIUS = 30 #pixel

var target : Node2D = null

@onready var origin : Node2D = get_parent().get_node("Path2D/PathFollow2D/Skull")

func _process(delta):
	global_position += (_get_pointer_target() - global_position) * delta * SPEED
	if target:
		look_at(target.global_position)
		if not $HandOpen.visible:
			$HandOpen.show()
		if $HandPoint.visible:
			$HandPoint.hide()
	else:
		look_at(2*global_position - origin.global_position)
		if $HandOpen.visible:
			$HandOpen.hide()
		if not $HandPoint.visible:
			$HandPoint.show()

func _get_pointer_target():
	if target and ((not target.is_dying) or (not target.is_dead)):
			var sprite : Sprite2D = target.get_node("CharacterUI/AnimRoot/Sprite2D")
			return sprite.global_position + OFFSET
	else:
		return _get_input_vector()*CIRCLE_RADIUS + origin.global_position

func _get_input_vector() -> Vector2:
	var inputVector = (get_global_mouse_position()-origin.global_position)
	if inputVector == Vector2.ZERO:
		return inputVector
	return inputVector.normalized()
