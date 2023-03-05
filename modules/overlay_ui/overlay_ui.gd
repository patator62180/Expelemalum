extends Control

@export var MOBILE_CONTROL_HELPER : Texture2D

@onready var _gameloop : Node2D = get_parent().get_parent().get_node("GameLoop")
@onready var _control_helper : TextureRect = get_node("GameplayScreen/ControlHelper")

func _ready():
	GameState.updated_game_phase.connect(_on_game_state_update)
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)
	$MenuScreen/MenuEnd/TextureButtonExit.pressed.connect(_on_texture_button_exit_pressed)
	$MenuScreen/MenuEnd/TextureButtonPlayAgain.pressed.connect(_on_texture_button_play_again_pressed)
	_on_exorcist_count_changed()
	if OS.get_name() == "Android" || OS.get_name() == "iOS":
		_control_helper.texture = MOBILE_CONTROL_HELPER
		

func _on_game_state_update(_previousState):
	if GameState.current_game_phase == GameState.GAME_PHASE.Outro:
		_on_exit_gameplay()

func _input(event : InputEvent):
	if (event.is_action_released("curse") or event.is_action_released("metamorphose")) && GameState.current_game_phase == GameState.GAME_PHASE.Intro:
		$AnimationPlayer.play("exit_intro")

func _on_enter_gameplay():
	GameState.updated_remaining_count.connect(_on_exorcist_count_changed)
	GameState.updated_kill_count.connect(_on_exorcist_killed)

func _on_exit_gameplay():
	$AnimationPlayer.play("enter_outro")
	GameState.updated_remaining_count.disconnect(_on_exorcist_count_changed)
	GameState.updated_kill_count.disconnect(_on_exorcist_killed)
	if GameState.game_won:
		$MenuScreen/MenuEnd/MessageDisplay.texture = preload("res://modules/overlay_ui/assets/victory.svg")
	else:
		$MenuScreen/MenuEnd/MessageDisplay.texture = preload("res://modules/overlay_ui/assets/defeat.svg")
	$MenuScreen/EndMessage/HBoxContainerAchievement/LabelValue.text = GameState.player_narration_state

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "exit_intro":
		_gameloop.start_gameplay()
		_on_enter_gameplay()
	elif anim_name == "enter_outro":
		if $AnimationPlayer.current_animation_position == 0:
			_on_enter_gameplay()
		else:
			_gameloop.destroy_world()
			

func _on_exorcist_killed(_killer, _victim):
	_on_exorcist_count_changed()

func _on_exorcist_count_changed():
	$GameplayScreen/ExorcistCounter/Label.text = str(GameState.exorcist_kill_count) + "/" + str(GameState.remaining_exorcists_count+GameState.exorcist_kill_count)

func _on_texture_button_exit_pressed():
	_gameloop.on_exit_game()

func _on_texture_button_play_again_pressed():
	_gameloop.on_restart()
	$AnimationPlayer.play_backwards("enter_outro")
