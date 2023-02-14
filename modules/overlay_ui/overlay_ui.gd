extends Control

enum SCREEN_TYPE {Intro,Gameplay,Outro}

@onready var animationPlayer : AnimationPlayer = get_node("AnimationPlayer")
@onready var gameloop : Node2D = get_parent().get_parent().get_node("gameLoop")
@onready var remaining_exorcists_label : Label = get_node("GameplayScreen/ExorcistCounter/Label")
@onready var winning_label : Label = get_node("MenuScreen/Outro/Label")
@onready var narration_state_label : Label = get_node("MenuScreen/Outro/Polygon2D/HBoxContainer/Label3")


var currentScreen : SCREEN_TYPE = SCREEN_TYPE.Intro

func _ready():
	gameloop.game_won.connect(game_won)
	gameloop.game_lost.connect(game_lost)

func _input(event : InputEvent):
	if (event.is_action_released("curse") or event.is_action_released("metamorphose")) && currentScreen == SCREEN_TYPE.Intro:
		animationPlayer.play("ExitIntro")
		gameloop.start_gameplay()

func _on_enter_gameplay():
	currentScreen = SCREEN_TYPE.Gameplay
	animationPlayer.play("EnterGameplay")
	GameState.updated_remaining_count.connect(_on_exorcist_count_changed)
	GameState.updated_kill_count.connect(_on_exorcist_killed)

func game_won():
	_on_exit_gameplay(true)

func game_lost():
	_on_exit_gameplay(false)

func _on_exit_gameplay(winning : bool):
	currentScreen = SCREEN_TYPE.Outro
	animationPlayer.play_backwards("EnterGameplay")
	GameState.updated_remaining_count.disconnect(_on_exorcist_count_changed)
	GameState.updated_kill_count.disconnect(_on_exorcist_killed)
	
	winning_label.text = "VICTORY" if winning else "DEFEAT"
	narration_state_label.text = GameState.player_narration_state

func _on_exit_game():
	gameloop.on_exit_game()

func _on_play_again_button_pressed():
	currentScreen = SCREEN_TYPE.Gameplay
	animationPlayer.play_backwards("EnterOutro")
	gameloop.on_restart()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ExitIntro" or (anim_name == "EnterOutro" and animationPlayer.current_animation_position == 0):
		_on_enter_gameplay()
	if anim_name == "EnterGameplay" && animationPlayer.current_animation_position == 0:
		animationPlayer.play("EnterOutro")
	if anim_name == "EnterOutro" && animationPlayer.current_animation_position != 0:
		gameloop.destroy_world()

func _on_exorcist_killed(killer, victim):
	_on_exorcist_count_changed()

func _on_exorcist_count_changed():
	remaining_exorcists_label.text = str(GameState.exorcist_kill_count) + "/" + str(GameState.remaining_exorcists_count+GameState.exorcist_kill_count)
	pass
