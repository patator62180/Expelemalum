extends Control

@export var MOBILE_CONTROL_HELPER : Texture2D

@onready var _gameloop : Node2D = get_parent().get_parent().get_node("gameLoop")
@onready var _remaining_exorcists_label : Label = get_node("GameplayScreen/ExorcistCounter/Label")
@onready var _winning_label : Label = get_node("MenuScreen/Outro/Label")
@onready var _narration_state_label : Label = get_node("MenuScreen/Outro/Polygon2D/HBoxContainer/Label3")
@onready var _play_again_button : Button = get_node("MenuScreen/Outro/PlayAgainButton")
@onready var _control_helper : TextureRect = get_node("GameplayScreen/ControlHelper")

func _ready():
	GameState.updated_game_phase.connect(_on_game_state_update)
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)
	_play_again_button.pressed.connect(_on_play_again_button_pressed)
	_on_exorcist_count_changed()
	if OS.get_name() == "Android" || OS.get_name() == "iOS":
		_control_helper.texture = MOBILE_CONTROL_HELPER
		

func _on_game_state_update(_previousState):
	if GameState.current_game_phase == GameState.GAME_PHASE.Outro:
		_on_exit_gameplay()

func _input(event : InputEvent):
	if (event.is_action_released("curse") or event.is_action_released("metamorphose")) && GameState.current_game_phase == GameState.GAME_PHASE.Intro:
		$AnimationPlayer.play("ExitIntro")

func _on_enter_gameplay():
	GameState.updated_remaining_count.connect(_on_exorcist_count_changed)
	GameState.updated_kill_count.connect(_on_exorcist_killed)

func _on_exit_gameplay():
	$AnimationPlayer.play("EnterOutro")
	GameState.updated_remaining_count.disconnect(_on_exorcist_count_changed)
	GameState.updated_kill_count.disconnect(_on_exorcist_killed)
	
	_winning_label.text = "VICTORY" if GameState.game_won else "DEFEAT"
	_narration_state_label.text = GameState.player_narration_state

func _on_exit_game():
	_gameloop.on_exit_game()

func _on_play_again_button_pressed():
	$AnimationPlayer.play_backwards("EnterOutro")
	_gameloop.on_restart()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ExitIntro":
		_gameloop.start_gameplay() # TODO: CHECK CONDITION
		_on_enter_gameplay()
	if anim_name == "EnterOutro" and $AnimationPlayer.current_animation_position == 0:
		_on_enter_gameplay()
	if anim_name == "EnterOutro" && $AnimationPlayer.current_animation_position != 0:
		_gameloop.destroy_world()

func _on_exorcist_killed(_killer, _victim):
	_on_exorcist_count_changed()

func _on_exorcist_count_changed():
	_remaining_exorcists_label.text = str(GameState.exorcist_kill_count) + "/" + str(GameState.remaining_exorcists_count+GameState.exorcist_kill_count)
