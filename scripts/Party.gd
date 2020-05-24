extends Node


var available_colors = [Color("9fbc4d"), Color("#bc4d4f"), Color("#fdc760"), Color("#4d92bc")]
var available_color_names = ["Verde", "Rojo", "Amarillo", "Azul"]

enum GameType {
	ALL_FOR_ALL = 1,
	ONE_VS_TWO = 2,
	ONE_VS_THREE = 4,
	TWO_VS_TWO = 8
}
var game_type = GameType.ALL_FOR_ALL
#var groups = [[0,1],[2,3]]
var groups = [[0, 1, 2, 3]]

#var rounds = 2
var rounds = 10
var current_round = 1

var _new_game = true

onready var Main = get_tree().get_root().get_node("Main") as Main
var _current_game = ""

# [{color, points}]
var _players: Array = [] setget , get_players

func load_test():
	_players = [{"color": 2, "points": 0}, {"color": -1, "points": 0}, {"color": 0, "points": 0}, {"color": 1, "points": 0}]

	# player 0
	_action_add_key("move_left_", 0, KEY_A)
	_action_add_key("move_right_", 0, KEY_D)
	_action_add_key("move_up_", 0, KEY_W)
	_action_add_key("move_down_", 0, KEY_S)
	_action_add_key("action_a_", 0, KEY_B)
	_action_add_key("action_b_", 0, KEY_N)
	
	#player 2
	_action_add_key("move_left_", 2, KEY_J)
	_action_add_key("move_right_", 2, KEY_L)
	_action_add_key("move_up_", 2, KEY_I)
	_action_add_key("move_down_", 2, KEY_K)
	_action_add_key("action_a_", 2, KEY_Z)
	_action_add_key("action_b_", 2, KEY_X)
	
	#player 3
	_action_add_key("move_left_", 3, KEY_LEFT)
	_action_add_key("move_right_", 3, KEY_RIGHT)
	_action_add_key("move_up_", 3, KEY_UP)
	_action_add_key("move_down_", 3, KEY_DOWN)
	_action_add_key("action_a_", 3, KEY_C)
	_action_add_key("action_b_", 3, KEY_V)

func _action_add_key(action, player_index: int, key):
	var ike: InputEventKey
	ike = InputEventKey.new()
	ike.scancode = key
	InputMap.action_add_event(action + str(player_index), ike)

func get_players():
	return _players

func _available_color(color):
	if color >= available_colors.size():
		return true
	for player in _players:
		if player.color == color:
			return false
	return true

func _get_available_colors():
	var colors = [0, 1, 2, 3]
	for player in _players:
		colors.erase(player.color)
	return colors

func _add_player():
	_players.append({"color": -1, "points": 0})

func _clear_player(index):
	if _players.size() > index:
		_players[index].color = -1

func _make_groups():
	match game_type:
		GameType.ALL_FOR_ALL:
			var group = []
			for i in range(_players.size()):
				if _players[i].color != -1:
					group.append(i)
			groups = [group]
		GameType.ONE_VS_TWO:
			var group = []
			for i in range(_players.size()):
				if _players[i].color != -1:
					group.append(i)
			var high_player = group[0]
			for i in range(_players.size()):
				if _players[i].points > _players[high_player].points:
					high_player = i
			group.erase(high_player)
			groups = [[high_player], group]
		GameType.ONE_VS_THREE:
			var group = range(_players.size())
			var high_player = 0
			for i in range(_players.size()):
				if _players[i].points > _players[high_player].points:
					high_player = i
			group.erase(high_player)
			groups = [[high_player], group]
		GameType.TWO_VS_TWO:
			var group = range(_players.size())
			var low_player = 0
			var high_player = 1
			for i in range(_players.size()):
				if _players[i].points < _players[low_player].points:
					low_player = i
				if _players[i].points > _players[high_player].points:
					high_player = i
			group.erase(low_player)
			group.erase(high_player)
			groups = [[high_player, low_player], group]


# [10, 20, 30]
func end_game(points):
	for i in range(_players.size()):
		_players[i].points += points[i]
	print(points)
	print("Game Finished")
	_next()

func get_color_name(index):
	return available_color_names[index]
	
func _next():
	Main.next()

func _game_over():
	Main.start_game()
