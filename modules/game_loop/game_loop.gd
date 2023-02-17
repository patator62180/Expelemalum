extends Node2D

@export var world_scene : PackedScene
@export var curse_scene : PackedScene

@onready var game : Node = get_parent()
@onready var world : Node2D = game.get_node("World")

func _ready():
	GameState.curse_killed.connect(on_game_state_cursed_killed)
	GameState.updated_remaining_count.connect(on_game_state_updated_remaining_count)

func on_game_state_updated_remaining_count():
	if GameState.remaining_exorcists_count < 1:
		GameState.game_won = true
		_exit_gameplay()

func on_game_state_cursed_killed():
	GameState.game_won = false
	_exit_gameplay()

func on_restart():
	GameState.reset_gamestate()
	initialise_world()
	start_gameplay()

func initialise_world():
	world = world_scene.instantiate()
	game.add_child(world)
	game.move_child(world,0)
	GameState.curse_killed.connect(on_game_state_cursed_killed)
	GameState.updated_remaining_count.connect(on_game_state_updated_remaining_count)

func start_gameplay():	
	GameState.start_gameplay()
	#spawn curse
	var curse = curse_scene.instantiate()
	curse.INITIALLY_CURSED_CHARACTER = "../"+str(world.get_node("Foreground").get_path_to(world.get_node("Playground").get_child(0)))
	world.get_node("Foreground").add_child(curse)	

func _exit_gameplay():	
	GameState.game_phase_update(GameState.GAME_PHASE.Outro)
	GameState.curse_killed.disconnect(on_game_state_cursed_killed)
	GameState.updated_remaining_count.disconnect(on_game_state_updated_remaining_count)

func destroy_world():
	world.queue_free()

func on_exit_game():
	get_tree().quit()
