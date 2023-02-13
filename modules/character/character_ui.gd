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
	character.killing.connect(_on_character_killing)
	character.dying.connect(_on_character_dying)
	character.horizontal_direction_changed_to_right.connect(_on_character_horizontal_direction_changed_to_right)
	character.horizontal_direction_changed_to_left.connect(_on_character_horizontal_direction_changed_to_left)

func _on_character_killing(victim : Node2D):
	$AnimationPlayerKill.play("kill")
	$AudioStreamPlayer2DKilling.play()

func _on_character_dying(killer : Node2D):
	var character : Node2D = get_character()
	match killer.character_type:
		character.CHARACTER_TYPE.Exorcist:
			assert(false, "TODO: DIE BY EXORCIST IN FLAMMES")
			$AudioStreamPlayer2DDyingExorcist.play()
		_:
			$AnimationPlayerMove.stop()
			$AnimationPlayerDie.play("die")
			$AudioStreamPlayer2DDyingDefault.play()

func _on_animation_die_red():
	pass

func _on_character_horizontal_direction_changed_to_right():
	$AnimationPlayerMove.speed_scale = -$AnimationPlayerMove.speed_scale

func _on_character_horizontal_direction_changed_to_left():
	$AnimationPlayerMove.speed_scale = -$AnimationPlayerMove.speed_scale
