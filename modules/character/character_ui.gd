extends Node2D

@export_node_path("Node2D") var CHARACTER_PATH : NodePath = NodePath("..")
@export var MOVING_SPEED_FACTOR : float = 0.0

func get_character() -> Node2D:
	return get_node(CHARACTER_PATH)

# internal

func _ready():
	var character : Node2D = get_character()
	# init
	$AnimationPlayerMove.seek(character.get_node("Behavior/AnimationPlayerMove").current_animation_position)
	$AnimationPlayerMove.speed_scale = character.get_node("Behavior/AnimationPlayerMove").speed_scale
	# connect
	character.horizontal_direction_changed_to_right.connect(_on_character_horizontal_direction_changed_to_right)
	character.horizontal_direction_changed_to_left.connect(_on_character_horizontal_direction_changed_to_left)
	character.killing.connect(_on_character_killing)
	character.killed.connect(_on_character_killed)
	character.dying.connect(_on_character_dying)

func _on_character_killing(_victim : Node2D):
	$AnimationPlayerMove.pause()
	$AnimationPlayerKill.play("kill")
	$AudioStreamPlayer2DKilling.play()

func _on_character_killed(_victim : Node2D):
	$AnimationPlayerMove.play()
	$AnimationPlayerKill.play("kill")
	$AudioStreamPlayer2DKilling.play()

func _on_character_dying(killer : Node2D):
	$AnimationPlayerMove.stop()
	$AnimationPlayerKill.stop()
	var character : Node2D = get_character()
	match killer.character_type:
		character.CHARACTER_TYPE.Exorcist:
			$AnimationPlayerDie.play("die_exorcist")
			$AudioStreamPlayer2DDyingExorcist.play()
		_:
			$AnimationPlayerDie.play("die")
			$AudioStreamPlayer2DDyingDefault.play()

func _on_animation_die_red():
	var character : Node2D = get_character()
	match character.killer.character_type:
		character.CHARACTER_TYPE.Exorcist:
			$AnimRoot/Sprite2D.texture = preload("res://modules/character/exorcists/assets/ashes.svg")
			$AnimRoot/Sprite2D.position = Vector2(0, -2)
		_:
			_on_animation_die_red_specific()

func _on_animation_die_red_specific():
	assert(false, "this method should be overloaded")

func _on_character_horizontal_direction_changed_to_right():
	$AnimationPlayerMove.speed_scale = -$AnimationPlayerMove.speed_scale

func _on_character_horizontal_direction_changed_to_left():
	$AnimationPlayerMove.speed_scale = -$AnimationPlayerMove.speed_scale
