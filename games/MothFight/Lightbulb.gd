tool
extends StaticBody2D


export (int, "Verde", "Rojo", "Amarillo", "Azul", "Blanco") var color setget set_color
export (bool) var on setget set_onoff
var controller
var colors = ["00ff00", "ff0000", "ffff00", "0000ff", "ffffff"]
var color_names = ["Verde", "Rojo", "Amarillo", "Azul", "Blanco"]

func _ready():
	set_color(color)
	controller = get_node("../../")

func set_color(color_index):
	color = color_index
	$Light2D.color = colors[color_index]

func switch(value):
	set_onoff(value)
	
func set_onoff(value):
	on = value
	$Light2D.enabled = on
	if on:
		$OnSound.play()
