extends Control

var score_text = "Score: "
var high_score_text = "High Score: "
var lives_text = "Lives: "


func _process(delta):
	$VBoxContainer/Score.text = score_text + "%020d" % Globals.score
	$VBoxContainer/High_Score.text = high_score_text + "%020d" % Globals.high_score
	$VBoxContainer/Lives.text = lives_text + str(Globals.num_lives)
