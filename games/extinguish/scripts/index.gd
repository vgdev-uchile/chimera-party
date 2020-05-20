extends Node2D


var Player = preload("res://games/extinguish/scenes/Player.tscn")

onready var Players = $Players

var players = Party.get_players()
var players_alive = []
var points = [0, 0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	Party.load_test()
#	players = Party.get_players()
	for i in range(players.size()):
		if players[i].color != -1:
			var player_inst = Player.instance()
			$Players.add_child(player_inst)
			player_inst.init(i, players[i].color)
			player_inst.connect("player_died", self, "on_player_died")
			players_alive.push_back(player_inst)
	
	var player_num = Players.get_child_count()
	for i in range(player_num):
		Players.get_child(i).global_position = \
			$Positions.get_child(player_num - 2).get_child(i).global_position
	
	$Area2D.connect("body_exited", self, "on_body_exited")
	$Timer.connect("timeout", self, "on_timeout")
	$Timer2.connect("timeout", self, "end_game")

func on_timeout():
	if players_alive.size() > 0:
		var player_index = players_alive[0].player_index
		points[player_index] = 100
		$CanvasLayer/Finish.text = "Gana P" + str(player_index + 1)
	else:
		$CanvasLayer/Finish.text = "Nadie Gana"
	for i in range(Players.get_child_count()):
		var player_index = Players.get_child(i).player_index
		var player_color = Players.get_child(i).player_color
		$CanvasLayer.get_child(i).text = "P" + str(player_index + 1) + " " + str(points[player_index])
		$CanvasLayer.get_child(i).modulate = Party.available_colors[player_color]
		$CanvasLayer.get_child(i).visible = true
	$Timer2.start()
	
func end_game():
	Party.end_game(points)

func on_body_exited(body: Node):
	if body.is_in_group("Player"):
		body.death()

func _physics_process(delta):
	var players = Players.get_children()
	players.sort_custom(self, "sort_by_y")
	for i in range(players.size()):
		players[i].z_index = i

func sort_by_y(a, b):
	return a.position.y < b.position.y

func on_player_died(player):
	points[player.player_index] = get_points(players_alive.size())
	players_alive.erase(player)
	if players_alive.size() == 1:
		$CanvasLayer/Finish.visible = true
		$Timer.start()
		players_alive[0].linear_damp *= 5
		players_alive[0].disabled = true

func get_points(player_position):
	var players_num = Players.get_child_count()
	match player_position:
		4:
			return 0
		3:
			return 25 if players_num == 4 else 0
		2:
			return 50 if players_num > 2 else 0
		1:
			return 50
