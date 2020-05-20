tool

extends TextureRect

#var green = preload("res://sprites/dinoCharactersVersion1.1/green/running.tres")
#var red = preload("res://sprites/dinoCharactersVersion1.1/red/running.tres")
#var yellow = preload("res://sprites/dinoCharactersVersion1.1/yellow/running.tres")
#var blue = preload("res://sprites/dinoCharactersVersion1.1/blue/running.tres")

var dino_colors = \
	[preload("res://sprites/dinoCharactersVersion1.1/green/running.tres"),
	preload("res://sprites/dinoCharactersVersion1.1/red/running.tres"),
	preload("res://sprites/dinoCharactersVersion1.1/yellow/running.tres"),
	preload("res://sprites/dinoCharactersVersion1.1/blue/running.tres")]

export(int, "green", "red", "yellow", "blue") var dino_color setget set_dino_color

export var ok : bool = false setget set_ok

func set_dino_color(new_value):
	dino_color = new_value
	texture = dino_colors[dino_color]
	
func set_ok(new_value):
	ok = new_value
	$OK.visible = ok
