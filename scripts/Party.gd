extends Node


var available_colors = [Color("9fbc4d"), Color("#bc4d4f"), Color("#fdc760"), Color("#4d92bc")]
var available_color_names = ["Verde", "Rojo", "Amarillo", "Azul"]

enum GameType {
	ALL_FOR_ALL,
	ONE_VS_TWO,
	ONE_VS_TREE,
	TWO_VS_TWO
}
var game_type = GameType.ALL_FOR_ALL
#var groups = [[0,1],[2,3]]
var groups = [[0, 1, 2, 3]]

onready var Main = get_tree().get_root().get_node("Main") as Main

# [{color, points}]
var _players: Array = [] setget , get_players


func get_players():
	return _players

func _available_color(color):
	if color >= available_colors.size():
		return true
	for player in _players:
		if player.color == color:
			return false
	return true

func _add_player():
	_players.append({"color": -1, "points": 0})

func _clear_player(index):
	if _players.size() > index:
		_players[index].color = -1


# [10, 20, 30]
func end_game(points):
	print(points)
	print("Game Finished")

func get_color_name(index):
	return available_color_names[index]
	
func _go_to_lobby():
	Main.load_lobby()

func _start():
	Main.start_game()
