@tool
extends Node2D

# TODO: MEMORY SYSTEM (should not be that hard I guess)

# testing interface (assuming this is only changed in the editor)

@export var BEHAVIOR_FRIENDLY : float = 1.0
@export var BEHAVIOR_KNOWING : float = 2.0

@export var SPEED : float = 40.0
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

# internal

var moving_direction : Vector2

var curiosity_direction : Vector2
var visible_characters : Array
var memory : Dictionary

func _ready():
	_on_timer_curiosity_timeout()

func _process(delta : float):
	if not Engine.is_editor_hint():
		# update memory
		for character in visible_characters:
			character = character as Node2D
			var direction_to_character : Vector2 = character.position - position
			var distance_to_character : float = direction_to_character.length()
			direction_to_character /= distance_to_character
			if distance_to_character > 0.0:
				memory[character]["known"] += pow(max(1.0, memory[character]["known"]), BEHAVIOR_KNOWING) * (RADIUS_VISION / distance_to_character) * delta
				memory[character]["love"] += pow(max(1.0, memory[character]["love"]), BEHAVIOR_FRIENDLY) * (RADIUS_VISION / distance_to_character) * delta
		for character in memory:
			if not character in visible_characters:
				character = character as Node2D
				memory[character]["known"] -= pow(max(1.0, memory[character]["known"]), BEHAVIOR_KNOWING) * delta
				memory[character]["love"] -= pow(max(1.0, memory[character]["love"]), BEHAVIOR_FRIENDLY) * delta
				if memory[character]["known"] <= 0.0:
					memory.erase(character)
		# control move_direction based on memory and visible characters
		if visible_characters:
			moving_direction = Vector2.ZERO
			for character in visible_characters:
				character = character as Node2D
				var direction_to_character : Vector2 = character.position - position
				var distance_to_character : float = direction_to_character.length()
				direction_to_character /= distance_to_character
				if distance_to_character > 0.0:
					moving_direction += memory[character]["love"] * direction_to_character / distance_to_character
					moving_direction -= memory[character]["known"] * direction_to_character / distance_to_character
			moving_direction = moving_direction.normalized()
			curiosity_direction = moving_direction
		else:
			moving_direction = curiosity_direction
		# move
		print("dir: ", moving_direction)
		position += SPEED * moving_direction * delta
		print("pos: ", position)

# signals

func _on_area_2d_vision_area_entered(area : Area2D):
	if not area == $Area2DBody:
		var character : Node2D = area.get_parent()
		visible_characters.append(character)
		if not character in memory:
			memory[character] = {"known":0.0, "love":0.0}

func _on_area_2d_vision_area_exited(area : Area2D):
	if not area == $Area2DBody:
		var character : Node2D = area.get_parent()
		visible_characters.erase(character)

func _on_timer_curiosity_timeout():
	curiosity_direction = Vector2.from_angle(randf_range(0.0, TAU))
