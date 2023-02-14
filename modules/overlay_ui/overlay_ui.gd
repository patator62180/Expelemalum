extends Control

@onready var animationPlayer : AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event : InputEvent):
	if event.is_action_released("curse"):
		animationPlayer.play("EnterGameplay")
	if event.is_action_released("metamorphose"):
		animationPlayer.play_backwards("EnterGameplay")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "EnterGameplay" && animationPlayer.current_animation_position == 0.0:
		animationPlayer.play("IdleIntro")
