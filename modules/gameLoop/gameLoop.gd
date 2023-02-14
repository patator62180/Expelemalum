extends Node2D

signal game_lost
signal game_won

@export var world_scene :PackedScene
@onready var game : Node = get_parent()


func on_game_state_updated_remaining_count():
	if GameState.remaining_exorcists_count < 1:
		_exit_gameplay()
		emit_signal("game_won")

func on_game_state_cursed_killed():
	_exit_gameplay()
	emit_signal("game_lost")

func on_restart():	
	game.get_node("World").queue_free()
	start_gameplay()

func start_gameplay():	
	var world = world_scene.instantiate()
	game.add_child(world)
	game.move_child(world,0)
	
	GameState.curse_killed.connect(on_game_state_cursed_killed)
	GameState.updated_remaining_count.connect(on_game_state_updated_remaining_count)

func _exit_gameplay():	
	GameState.curse_killed.disconnect(on_game_state_cursed_killed)
	GameState.updated_remaining_count.disconnect(on_game_state_updated_remaining_count)

func on_exit_game():
	get_tree().quit()
