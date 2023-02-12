@tool
extends Node2D

@export_node_path("Node2D") var INITIALLY_CURSED_CHARACTER : NodePath
var cursed_character : Node2D = null

var area_array : Array

signal curse
signal cantCurse

@export var CURSE_RANGE : float:
	get:
		return CURSE_RANGE
	set(value):
		CURSE_RANGE = value
		if Engine.is_editor_hint():
			$Area2DUp/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(-CURSE_RANGE, -CURSE_RANGE), Vector2(CURSE_RANGE, -CURSE_RANGE)]
			$Area2DDown/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(CURSE_RANGE, CURSE_RANGE), Vector2(-CURSE_RANGE, CURSE_RANGE)]
			$Area2DLeft/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(-CURSE_RANGE, -CURSE_RANGE), Vector2(-CURSE_RANGE, CURSE_RANGE)]
			$Area2DRight/CollisionPolygon2D.polygon = [Vector2.ZERO, Vector2(CURSE_RANGE, CURSE_RANGE), Vector2(CURSE_RANGE, -CURSE_RANGE)]

# internal

func _ready():
	_curse(get_node(INITIALLY_CURSED_CHARACTER))

func _curse(character : Node2D):
	if not Engine.is_editor_hint():
		if cursed_character:
			cursed_character.is_cursed = true
			cursed_character.tree_exiting.disconnect(queue_free)
		cursed_character = character
		cursed_character.tree_exiting.connect(queue_free)
		cursed_character.is_cursed = false
		emit_signal("curse")

func _process(delta : float):
	if not Engine.is_editor_hint():
		global_position = cursed_character.global_position
		if area_array:
			_highlightCursableCharacters(area_array, false)
		area_array = _process_area_array()
		_highlightCursableCharacters(area_array, true)

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
						emit_signal("cantCurse")

func _process_area_array() -> Array:
	if not Engine.is_editor_hint():
		var area_array : Array = []
		area_array.append_array($Area2DUp.get_overlapping_areas().duplicate())
		area_array.append_array($Area2DDown.get_overlapping_areas().duplicate())
		area_array.append_array($Area2DLeft.get_overlapping_areas().duplicate())
		area_array.append_array($Area2DRight.get_overlapping_areas().duplicate())
		area_array.erase(cursed_character.get_node("Area2DBody"))
		
		return area_array
	else:
		return []

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


func _on_tree_exiting():
	GameState.IsCurseAlive= false

func _highlightCursableCharacters(area_array : Array, enable : bool):
	for area in area_array:
		var character : Node2D = area.get_parent()
		if character != cursed_character:
			var polygon : Polygon2D = character.get_node("Polygon2D")
			polygon.color = Color.YELLOW if enable else Color.WHITE
			
	
