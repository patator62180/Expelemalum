@tool
extends Node2D

## signals

signal killing(victim_character)
signal killed(victim_character)
signal dying(killer_character)
signal died(killer_character)

signal horizontal_direction_changed_to_right
signal horizontal_direction_changed_to_left

# testing interface (assuming this is only changed in the editor)
@export var SPEED : float

@export var RADIUS_BODY : float:
	get:
		return RADIUS_BODY
	set(value):
		RADIUS_BODY = value
		if is_inside_tree():
			$Area2DBody/CollisionShape2D.shape.radius = RADIUS_BODY
		
@export var RADIUS_VISION : float:
	get:
		return RADIUS_VISION
	set(value):
		RADIUS_VISION = value
		if is_inside_tree():
			$Area2DVision/CollisionShape2D.shape.radius = RADIUS_VISION


enum CHARACTER_TYPE { Lumberjack, Exorcist}
@export var character_type : CHARACTER_TYPE

## movement variables
var moving_direction : Vector2 = Vector2.ZERO
var is_moving_to_the_right : bool = true

## dying variables
var is_dying : bool = false
var killer : Node2D = null

## killing variables
var is_killing : bool = false
var victim : Node2D = null

## cursed state variable
var is_cursed : bool = false

# boundary variables
var containing_boundaries : Array
var last_boundary : Area2D = null

## vision variables
var visible_characters : Array = []

# interface

func kill(victim_character : Node2D):
	if not is_killing and (victim_character != null) and (not victim_character.is_queued_for_deletion()):
		is_killing = true
		victim = victim_character
		$TimerKillDelay.start()
		emit_signal("killing", victim)

func _on_timer_kill_delay_timeout():
	victim.die(self)
	emit_signal("killed", victim)
	is_killing = false
	victim = null

func die(killer_character : Node2D):
	if not is_dying:
		is_dying = true
		killer = killer_character
		$TimerDieDelay.start()
		emit_signal("dying", killer)

func _on_timer_die_delay_timeout():
	if not Engine.is_editor_hint():
		# create corps
		var corps_node : Node2D = preload("res://modules/character/corps.tscn").instantiate()
		get_parent().add_child(corps_node)
		var sprite_2d : Sprite2D = $CharacterUI/AnimRoot/Sprite2D
		corps_node.global_position = sprite_2d.global_position
		corps_node.global_rotation = sprite_2d.global_rotation
		$CharacterUI/AnimRoot.remove_child(sprite_2d)
		sprite_2d.position = Vector2.ZERO
		sprite_2d.rotation = 0.0
		sprite_2d.modulate = Color.WHITE
		corps_node.add_child(sprite_2d)
		# self free
		queue_free()

# internal functions

func _ready():
	set("RADIUS_BODY", RADIUS_BODY)
	set("RADIUS_VISION", RADIUS_VISION)

func _process(delta : float):
	if not Engine.is_editor_hint():
		moving_direction = $Behavior.get_moving_direction()
		# animation
		if moving_direction.dot(Vector2.RIGHT) > 0.0:
			if not is_moving_to_the_right:
				emit_signal("horizontal_direction_changed_to_right")
			is_moving_to_the_right = true
		else:
			if is_moving_to_the_right:
				emit_signal("horizontal_direction_changed_to_left")
			is_moving_to_the_right = false

func _on_character_got_at_close_range(character : Node2D):
	pass # TO BE OVERLOADED

# signals

func _on_area_2d_vision_area_entered(area : Area2D):
	if not area == $Area2DBody:
		var character : Node2D = area.get_parent()
		visible_characters.append(character)

func _on_area_2d_vision_area_exited(area : Area2D):
	if not area == $Area2DBody:
		var character : Node2D = area.get_parent()
		visible_characters.erase(character)

func _on_area_2d_boundary_check_area_entered(area : Area2D):
	containing_boundaries.append(area)

func _on_area_2d_boundary_check_area_exited(area : Area2D):
	containing_boundaries.erase(area)
	if containing_boundaries.is_empty():
		last_boundary = area

func _on_area_2d_close_range_area_entered(area : Area2D):
	if not area == $Area2DBody:
		_on_character_got_at_close_range(area.get_parent())
