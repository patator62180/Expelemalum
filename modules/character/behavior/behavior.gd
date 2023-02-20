extends Node

@export_node_path("Node2D") var CHARACTER_PATH : NodePath = NodePath("..")

@export var PERSONALITY_SOCIABILITY : float
@export var PERSONALITY_CURIOSITY : float
@export var PERSONALITY_BOUNDARY_FEAR : float
@export var PERSONALITY_COWARD : float

@export var TIMER_CURIOSITY_WAIT_TIME : float
@export_range(0.0, 1.0) var TIMER_CURIOSITY_WAIT_TIME_RANDOM : float

@export var SPEED_FACTOR : float

const BOUNDARY_MARGING : float = 10.0

func get_character() -> Node2D:
	return get_node(CHARACTER_PATH)

func get_moving_direction() -> Vector2:
	# init
	var moving_direction : Vector2 = Vector2.ZERO
	var character : Node2D = get_character()
	# compute
	if not character.inner_boundaries.is_empty() or not character.last_inner_boundary:
		if character.visible_characters:
			moving_direction = _get_moving_direction()
			curiosity_direction = moving_direction
			$TimerCuriosity.stop()
		else:
			$TimerCuriosity.start()
			moving_direction = curiosity_direction
	else:
		boundary_exits.append({"position":character.global_position + BOUNDARY_MARGING * (character.global_position - character.last_inner_boundary.global_position).normalized(), "know":1.0})
		moving_direction = (character.last_inner_boundary.global_position - character.global_position).normalized()
		curiosity_direction = moving_direction
		$TimerCuriosity.stop()
	return moving_direction

# internal

## boundary variables

var boundary_exits : Array = []

## behavior variables

var curiosity_direction : Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
var memory : Dictionary

func _ready():
	# randomize moving animation
	$AnimationPlayerMove.seek(randf_range(0, 1))
	# start curiosity
	_on_timer_curiosity_timeout()
	# connect
	var character : Node2D = get_character()
	character.get_node("Area2DVision").area_entered.connect(_on_character_area_2d_vision_area_entered)
	character.entered_outer_boundary.connect(_on_character_entered_outer_boundary)
	character.dying.connect(_on_character_dying)
	character.killing.connect(_on_character_killing)
	character.killed.connect(_on_character_killed)

func _process(delta : float):
	# update boundary exits
	for boundary_exit in boundary_exits.duplicate():
		boundary_exit["know"] -= delta
		if boundary_exit["know"] < 0.0:
			boundary_exits.erase(boundary_exit)
	# movement
	var character : Node2D = get_character()
	character.position += (character.SPEED * SPEED_FACTOR) * character.moving_direction * delta

func _get_moving_direction() -> Vector2:
	# init
	var character : Node2D = get_character()
	var moving_direction : Vector2 = Vector2.ZERO
	# compute
	for other_character in character.visible_characters:
		if other_character != null and not other_character.is_queued_for_deletion() and not other_character.is_dying:
			other_character = other_character as Node2D
			var direction_to_other_character : Vector2 = other_character.global_position - character.global_position
			var distance_to_other_character : float = direction_to_other_character.length()
			direction_to_other_character /= distance_to_other_character
			if distance_to_other_character > 0.0:
				moving_direction += PERSONALITY_SOCIABILITY * memory[other_character]["love"] * direction_to_other_character / distance_to_other_character
				moving_direction -= PERSONALITY_CURIOSITY * memory[other_character]["know"] * direction_to_other_character / distance_to_other_character
				moving_direction -= PERSONALITY_COWARD * memory[other_character]["fear"] * direction_to_other_character / distance_to_other_character
	for boundary_exit in boundary_exits:
		var direction_to_boundary_exit : Vector2 = boundary_exit["position"] - character.global_position
		var distance_to_boundary_exit : float = direction_to_boundary_exit.length()
		direction_to_boundary_exit /= distance_to_boundary_exit
		if distance_to_boundary_exit > 0.0:
			moving_direction -= PERSONALITY_BOUNDARY_FEAR * boundary_exit["know"] * direction_to_boundary_exit / distance_to_boundary_exit
	return moving_direction.normalized()

# signals

func _on_character_entered_outer_boundary(outer_boundary : Area2D):
	var character : Node2D = get_character()
	boundary_exits.append({"position":character.global_position + BOUNDARY_MARGING * (outer_boundary.global_position - character.global_position).normalized(), "know":1.0})
	$TimerCuriosity.stop()

func _on_character_area_2d_vision_area_entered(area : Area2D):
	if not area == get_character().get_node("Area2DBody"):
		var character : Node2D = area.get_parent()
		if not character in memory: 
			memory[character] = {}
			for behavior_rule in $MemoryRules.get_children():
				memory[character][behavior_rule.NAME] = 0.0

func _on_character_dying(_killer : Node2D):
	$AnimationPlayerMove.stop()

func _on_character_killing(_victim : Node2D):
	$AnimationPlayerMove.pause()

func _on_character_killed(_victim : Node2D):
	$AnimationPlayerMove.play()

func _on_timer_curiosity_timeout():
	curiosity_direction = (CharacterCenter.global_position - get_character().global_position).rotated(0.1 * TAU * randf_range(-1.0, 1.0))
	if curiosity_direction == Vector2.ZERO:
		curiosity_direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	$TimerCuriosity.wait_time = TIMER_CURIOSITY_WAIT_TIME * randf_range((1.01 - TIMER_CURIOSITY_WAIT_TIME_RANDOM), (1.0 + TIMER_CURIOSITY_WAIT_TIME_RANDOM))
	$TimerCuriosity.start()
