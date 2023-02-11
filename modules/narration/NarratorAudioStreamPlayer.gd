extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _play_line(lineName : String):
	var audioStream = load("res://modules/narration/Audio/"+lineName+".wav")
	stream = audioStream
	play()
