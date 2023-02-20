extends Control

@onready var animationPlayer : AnimationPlayer = get_node("AnimationPlayer")
@onready var gameloop : Node2D = get_parent().get_parent().get_node("gameLoop")
@onready var remaining_exorcists_label : Label = get_node("GameplayScreen/ExorcistCounter/Label")
@onready var winning_label : Label = get_node("MenuScreen/Outro/Label")
@onready var narration_state_label : Label = get_node("MenuScreen/Outro/Polygon2D/HBoxContainer/Label3")

func _ready():
	GameState.updated_game_phase.connect(_on_game_state_update)
	_on_exorcist_count_changed()

func _on_game_state_update(previousState):
	if GameState.current_game_phase == GameState.GAME_PHASE.Outro:
		_on_exit_gameplay()

func _input(event : InputEvent):
	if (event.is_action_released("curse") or event.is_action_released("metamorphose")) && GameState.current_game_phase == GameState.GAME_PHASE.Intro:
		animationPlayer.play("ExitIntro")

func _on_enter_gameplay():
	GameState.updated_remaining_count.connect(_on_exorcist_count_changed)
	GameState.updated_kill_count.connect(_on_exorcist_killed)

func _on_exit_gameplay():
	animationPlayer.play("EnterOutro")
	GameState.updated_remaining_count.disconnect(_on_exorcist_count_changed)
	GameState.updated_kill_count.disconnect(_on_exorcist_killed)
	
	winning_label.text = "Victory" if GameState.game_won else "Defeat"
	narration_state_label.text = GameState.player_narration_state

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ExitIntro":
		gameloop.start_gameplay() # TODO: CHECK CONDITION
		_on_enter_gameplay()
	if anim_name == "EnterOutro" and animationPlayer.current_animation_position == 0:
		_on_enter_gameplay()
	if anim_name == "EnterOutro" && animationPlayer.current_animation_position != 0:
		gameloop.destroy_world()

func _on_exorcist_killed(killer, victim):
	_on_exorcist_count_changed()

func _on_exorcist_count_changed():
	remaining_exorcists_label.text = str(GameState.exorcist_kill_count) + "/" + str(GameState.remaining_exorcists_count+GameState.exorcist_kill_count)

func _on_texture_button_play_exit_pressed():
	gameloop.on_exit_game()

func _on_texture_button_play_again_pressed():
	animationPlayer.play_backwards("EnterOutro")
	gameloop.on_restart()
