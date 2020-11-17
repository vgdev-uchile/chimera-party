extends Node2D

var Player = preload("res://games/scrap_road/scenes/Car.tscn")

onready var Players = $Players
var players

var waiting = true
var last_timer_state = 4
var points = [0, 0, 0, 0]

func _ready():
	players = Party.get_players()
	for i in range(players.size()):
		if players[i].color != -1:
			var player_inst = Player.instance()
			$Players.add_child(player_inst)
			player_inst.init(i, players[i].color)
	var player_num = Players.get_child_count()
	for i in range(player_num):
		Players.get_child(i).global_position = \
			$Positions.get_child(i).global_position
	
	waiting = true
	last_timer_state = 4
	points = [0, 0, 0, 0]
	
	$StartTimer.connect("timeout", self, "on_start_timeout")
	$EndTimer.connect("timeout", self, "on_end_timeout")
	$Announce_Timer.connect("timeout", self, "on_finish_timeout")

func _process(delta):
	if waiting:
		var time_left = stepify($StartTimer.time_left,1)
		if time_left > 0:
			$Overlay/CountLabel.text = str(time_left)
		else:
			$Overlay/CountLabel.text = "go!"
		
		if last_timer_state != time_left:
				last_timer_state = time_left
				if time_left > 0:
					$SFX_READY.play()
				else:
					$SFX_GO.play()

func start():
	self.waiting = false
	$Overlay/CountLabel.visible = false
	$Overlay/RaceTimer.visible = true
	$RoadMusic.play()
	
	$BoxSpawner.set_active(true)
	var players = $Players.get_children()
	for player in players:
		player.set_active(true)

func on_start_timeout():
	start()
	$EndTimer.start()

func on_end_timeout():
	var players = $Players.get_children()
	for player in players:
		player.set_active(false)
	$Announce_Timer.start()
	announce_winner()

func on_finish_timeout():
	self.finish_game()

func announce_winner():
	var players = Players.get_children()
	var my_players = Array()
	for player in players:
		my_players.append(player)
	
	my_players.sort_custom(self, "sort_by_y")
	
	$Overlay/CountLabel.text = "Results"
	var award_points = 100
	for player in my_players:
		points[player.get_index()] = award_points
		award_points -= 25
		$Overlay/CountLabel.text += "\nPlayer " + str(player.get_index() + 1)
		
	$Overlay/CountLabel.visible = true

func finish_game():
	var players = Players.get_children()
	var my_players = Array()
	for player in players:
		my_players.append(player)
	
	my_players.sort_custom(self, "sort_by_y")
	
	var award_points = 100
	for player in my_players:
		points[player.get_index()] = award_points
		award_points -= 25
		
	Party.end_game(points)

func _physics_process(delta):
	var players = Players.get_children()
	players.sort_custom(self, "sort_by_y")
	for i in range(players.size()):
		players[i].z_index = i - 15

func sort_by_y(a, b):
	return a.position.y < b.position.y
