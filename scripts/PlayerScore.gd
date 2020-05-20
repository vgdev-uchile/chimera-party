tool

extends HBoxContainer

export(int, "green", "red", "yellow", "blue") var dino_color setget set_dino_color
export var score : String = "0" setget set_score


func set_dino_color(new_value):
	dino_color = new_value
	$Dino.set_dino_color(new_value)

func set_score(new_value):
	score = str(new_value)
	$Score.text = str(new_value)
