extends Node
const player_factory = preload("res://scripts/Player.gd")


var players = Dictionary()
var player_colors = Dictionary()


# Called when the node enters the scene tree for the first time.
func _ready():
	player_colors[0] = Color(1,1,1)
	player_colors[1] = Color(0.5,0.5,0.5)
	player_colors[2] = Color(1.0,0.0,0.0)
	player_colors[3] = Color(0.0,0.0,1.0)

# add_player: int -> None
# adds a player to the dictionary
func add_player(num):
	assert(num < 4 and num >= 0 and typeof(num) == 2, "Cant add player with index higher than 3 and lower than 0.")
	
	var player = player_factory.new()
	player.set_player_id(num)
	player.set_player_color(player_colors[num])
	players[num] = player

# remove_player: int -> None
# Removes a player form the players dictionary
func remove_player(num):
	players.erase(num)

# getter
func get_players():
	return players
