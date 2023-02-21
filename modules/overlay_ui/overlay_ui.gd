extends Control

@onready var game_loop : Node2D = get_tree().root.get_node("Game/gameLoop")

func _ready():
	GameState.updated_game_phase.connect(_on_game_state_update)
	_on_exorcist_count_changed()

func _on_game_state_update(previousState):
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
	$MenuScreen/HBoxContainerAchievement/LabelValue.text = GameState.player_narration_state

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "exit_intro":
		game_loop.start_gameplay()
		_on_enter_gameplay()
	if anim_name == "enter_outro" and $AnimationPlayer.current_animation_position == 0:
		game_loop.destroy_world()
		_on_enter_gameplay()

func _on_exorcist_killed(killer, victim):
	_on_exorcist_count_changed()

func _on_exorcist_count_changed():
	$GameplayScreen/ExorcistCounter/Label.text = str(GameState.exorcist_kill_count) + "/" + str(GameState.remaining_exorcists_count+GameState.exorcist_kill_count)

func _on_texture_button_play_exit_pressed():
	game_loop.on_exit_game()

func _on_texture_button_play_again_pressed():
	$AnimationPlayer.play_backwards("enter_outro")
	game_loop.on_restart()
