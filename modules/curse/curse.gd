@tool
extends Node2D

@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath
var cursed_character : Node2D = null

@export var JUMP_RANGE : float:
	get:
		return JUMP_RANGE
	set(value):
		JUMP_RANGE = value
		if Engine.is_editor_hint():
			$Area2DUp/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(-JUMP_RANGE, -JUMP_RANGE), Vector2(JUMP_RANGE, -JUMP_RANGE)]
			$Area2DDown/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(JUMP_RANGE, JUMP_RANGE), Vector2(-JUMP_RANGE, JUMP_RANGE)]
			$Area2DLeft/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(-JUMP_RANGE, -JUMP_RANGE), Vector2(-JUMP_RANGE, JUMP_RANGE)]
			$Area2DRight/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(JUMP_RANGE, JUMP_RANGE), Vector2(JUMP_RANGE, -JUMP_RANGE)]

# internal

func _ready():
	_curse(get_node(INITIALLY_CURSED_CHARACTER))

func _curse(character : Node2D):
	cursed_character = character
	cursed_character.is_cursed = true

func _process(delta : float):
	if not Engine.is_editor_hint():
		global_position = cursed_character.global_position

func _input(event : InputEvent):
	if not Engine.is_editor_hint():
		if event is InputEventJoypadMotion:
			pass # TODO MANAGE JOYPAD
		elif event is InputEventKey:
				if not event.pressed:
					var area_array : Array = []
					if event.is_action("up"):
						area_array = $Area2DUp.get_overlapping_areas().duplicate()
						area_array.erase(cursed_character.get_node("Area2DBody"))
					elif event.is_action("down"):
						area_array = $Area2DDown.get_overlapping_areas().duplicate()
						area_array.erase(cursed_character.get_node("Area2DBody"))
					elif event.is_action("left"):
						area_array = $Area2DLeft.get_overlapping_areas().duplicate()
						area_array.erase(cursed_character.get_node("Area2DBody"))
					elif event.is_action("right"):
						area_array = $Area2DRight.get_overlapping_areas().duplicate()
						area_array.erase(cursed_character.get_node("Area2DBody"))
					elif event.is_action("activate"):
						if not cursed_character.is_metamorphosed:
							cursed_character.metamorphose()
					# CHANGE CHARACTER IF NECESSARY
					if area_array:
						_curse(_get_closest_character(area_array))
					else:
						pass

func _get_closest_character(area_array : Array) -> Node2D:
	var closest_character : Node2D = null
	var closest_character_distance : float = INF
	for area in area_array:
		var character : Node2D = area.get_parent()
		if character != cursed_character:
			var character_distance : float = (character.global_position - cursed_character.global_position).length()
			if character_distance < closest_character_distance:
				closest_character = character
				closest_character_distance = character_distance
	return closest_character
