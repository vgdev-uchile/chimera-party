extends CenterContainer

var score = 0
var color = ""
var color_name = ""

var available_colors = [Color("00ff00"), Color("ff0000"), Color("ffff00"), Color("0000ff")]

func _ready():
	add_score(0)

func set_color(col):
	color_name = col
	match col:
		"Amarillo":
			color = "yellow"
		"Rojo":
			color = "red"
		"Verde":
			color = "lime"
		"Azul":
			color = "blue"

func add_score(value):
	score += value
	$Panel/ScoreLabel.parse_bbcode("[center]{score}[/center]".format({"score": score}))
