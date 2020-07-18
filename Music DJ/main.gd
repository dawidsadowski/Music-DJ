extends Control

var song = [[], [], [], []]

func _ready():
	var step_scene = preload("res://Step.tscn")
	for i in 25:
		var step = step_scene.instance()
		step.get_node("Label").text = str(i + 1)
		get_node("HBoxContainer/StepContainer/HBoxContainer").add_child(step)
		
		# Signals
		step.get_node("Button1").connect("pressed", self, "button", [i, 0])
		step.get_node("Button2").connect("pressed", self, "button", [i, 1])
		step.get_node("Button3").connect("pressed", self, "button", [i, 2])
		step.get_node("Button4").connect("pressed", self, "button", [i, 3])
		
		
		for g in song:
			g.append(0)


func _process(delta):
	pass


func play():
	for i in 25:
		for a in 4:
			if song[a][i] == 0:
				continue
			var audio_player = $AudioPlayers.get_child(a)
			var sound = song[a][i]
			audio_player.stream = load("res://sounds/"+str(a)+"/"+str(sound)+".wav")
			audio_player.play()
		yield(get_tree().create_timer(3), "timeout")


func button(_column, _instrument):
	$SoundDialog.instrument_index = _instrument
	$SoundDialog.column = _column
	$SoundDialog.popup_centered()
	


func _on_Button_pressed():
	play()
