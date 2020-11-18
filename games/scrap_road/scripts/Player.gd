extends Node


# Declare member variables here. Examples:
var player_id = 0
var player_color = Color(1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#getters
func get_player_id():
	return self.player_id

func get_player_color():
	return self.player_color

# setters
func set_player_id(new_id):
	player_id = new_id

func set_player_color(new_color):
	player_color = new_color
