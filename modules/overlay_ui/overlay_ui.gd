extends Control

enum SCREEN_TYPE {Intro,Gameplay,Outro}

@onready var animationPlayer : AnimationPlayer = get_node("AnimationPlayer")
@onready var gameloop : Node2D = get_parent().get_parent().get_node("gameLoop")

var currentScreen : SCREEN_TYPE = SCREEN_TYPE.Intro

#func _onready():
#	gameloop.game_won.connect(_on_exit_gameplay)
#	gameloop.game_lost.connect(_on_exit_gameplay)


func _input(event : InputEvent):
	if (event.is_action_released("curse") or event.is_action_released("metamorphose")) && currentScreen == SCREEN_TYPE.Intro:
		currentScreen = SCREEN_TYPE.Gameplay
		animationPlayer.play("ExitIntro")
		gameloop.start_gameplay()

func _on_exit_gameplay():
	currentScreen = SCREEN_TYPE.Outro
	animationPlayer.play_backwards("EnterGameplay")

func _on_exit_game():
	gameloop.on_exit_game()

func _on_play_again_button_pressed():
	currentScreen = SCREEN_TYPE.Gameplay
	animationPlayer.play_backwards("EnterOutro")
	gameloop.on_restart()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ExitIntro" or (anim_name == "EnterOutro" and animationPlayer.current_animation_position == 0):
		animationPlayer.play("EnterGameplay")
	if anim_name == "EnterGameplay" && animationPlayer.current_animation_position == 0:
		animationPlayer.play("EnterOutro")
	if anim_name == "EnterOutro" && animationPlayer.current_animation_position != 0:
		gameloop.destroy_world()
