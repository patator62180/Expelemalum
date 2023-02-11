@tool
extends Node2D

# TODO: ADD PERSONALITY (CURIOSITY, SOCIABILITY, ...)

const PERSONALITY_SOCIABILITY : float = 1.0
const PERSONALITY_CURIOSITY : float = 0.5

# testing interface (assuming this is only changed in the editor)

const SPEED : float = 40.0

@export var RADIUS_BODY : float = 10.0:
	get:
		return RADIUS_BODY
	set(value):
		RADIUS_BODY = value
		if Engine.is_editor_hint():
			$Area2DBody/CollisionShape2D.shape.radius = RADIUS_BODY
		
@export var RADIUS_VISION : float = 40.0:
	get:
		return RADIUS_VISION
	set(value):
		RADIUS_VISION = value
		if Engine.is_editor_hint():
			$Area2DVision/CollisionShape2D.shape.radius = RADIUS_VISION

@export var RADIUS_CLOSE_RANGE : float = 15.0:
	get:
		return RADIUS_CLOSE_RANGE
	set(value):
		RADIUS_CLOSE_RANGE = value
		if Engine.is_editor_hint():
			$Area2DCloseRange/CollisionShape2D.shape.radius = RADIUS_CLOSE_RANGE

## signal

signal died(dieType)

## behavior variables

var moving_direction : Vector2

var curiosity_direction : Vector2
var visible_characters : Array
var memory : Dictionary

@onready
var SFXPlayer = $SFXPlayer

## boundary variables

var containing_boundaries : Array
var last_boundary : Area2D = null

## cursed variables

var is_cursed : bool = false
# interface

func die(die_type):
	emit_signal("died", die_type) #need to retest when corpse implemented
	queue_free()

# internal functions

func _ready():
	# randomize curiosity direction
	_on_timer_curiosity_timeout()

func _process(delta : float):
	if not Engine.is_editor_hint():
		# update memory
		for behavior_rule in $BehaviorRules.get_children():
			behavior_rule.update_memory(delta, visible_characters)
		# control move_direction based on memory and visible characters
		if not containing_boundaries.is_empty() or not last_boundary:
			if visible_characters:
				_choose_moving_direction()
				curiosity_direction = moving_direction
			else:
				moving_direction = curiosity_direction
		else:
			moving_direction = (last_boundary.global_position - global_position).normalized()
			_on_timer_curiosity_timeout()
		# move
		position += SPEED * moving_direction * delta

func _choose_moving_direction():
	moving_direction = Vector2.ZERO
	for character in visible_characters:
		character = character as Node2D
		var direction_to_character : Vector2 = character.global_position - global_position
		var distance_to_character : float = direction_to_character.length()
		direction_to_character /= distance_to_character
		if distance_to_character > 0.0:
			moving_direction += PERSONALITY_SOCIABILITY * memory[character]["love"] * direction_to_character / distance_to_character
			moving_direction -= PERSONALITY_CURIOSITY * memory[character]["know"] * direction_to_character / distance_to_character
	moving_direction = moving_direction.normalized()

func _on_character_got_at_close_range(character : Node2D):
	pass # TO BE OVERLOADED

# signals

func _on_area_2d_vision_area_entered(area : Area2D):
	if not area == $Area2DBody:
		var character : Node2D = area.get_parent()
		visible_characters.append(character)
		if not character in memory:
			memory[character] = {}
			for behavior_rule in $BehaviorRules.get_children():
				memory[character][behavior_rule.NAME] = 0.0

func _on_area_2d_vision_area_exited(area : Area2D):
	if not area == $Area2DBody:
		var character : Node2D = area.get_parent()
		visible_characters.erase(character)

func _on_timer_curiosity_timeout():
	curiosity_direction = Vector2.from_angle(randf_range(0.0, TAU))

func _on_area_2d_boundary_check_area_entered(area : Area2D):
	containing_boundaries.append(area)

func _on_area_2d_boundary_check_area_exited(area : Area2D):
	containing_boundaries.erase(area)
	if containing_boundaries.is_empty():
		last_boundary = area

func _on_area_2d_close_range_area_entered(area : Area2D):
	if not area == $Area2DBody:
		_on_character_got_at_close_range(area.get_parent())
