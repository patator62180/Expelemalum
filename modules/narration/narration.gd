extends Control


@onready
var narratorStreamPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
enum AUDIO_LINE {Everyday , Exorcism, Intro, TooMuchTrigger}

func _ready():
	GameState.updated.connect(_on_game_state_updated)

func _on_game_state_updated():
	if(GameState.KillCount == 1):
		narratorStreamPlayer._play_line(AUDIO_LINE.keys()[AUDIO_LINE.Everyday])
