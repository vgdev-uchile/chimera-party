extends Node2D

var Player = preload("res://games/hideout_gouge/scenes/Player.tscn")
onready var owlBear = $owlBear
onready var Players = $Players
var players
var players_score = [0, 0, 0, 0]
var dead_players = []
var scores = [0, 15, 50, 50]
var player_num
var available_colors = ["#9fbc4d", "#bc4d4f", "#fdc760", "#4d92bc"]
var game_over = false

func _ready():
#	Party.load_test()
	players = Party.get_players()
	for i in range(players.size()):
		if players[i].color != -1:
			var player_inst = Player.instance()
			$Players.add_child(player_inst)
			player_inst.init(i, players[i].color)
	player_num = Players.get_child_count()
	for i in range(player_num):
		Players.get_child(i).global_position = \
			$Positions.get_child(i).global_position
	
	$Timer.connect("timeout", self, "on_timeout")
	$Timer2.connect("timeout", self, "on_timeout2")

func on_timeout():
	game_over()
	
func _physics_process(delta):
	check_dead_players()
	var players = Players.get_children()
	players.sort_custom(self, "sort_by_y")
	for i in range(players.size()):
		players[i].z_index = i

func sort_by_y(a, b):
	return a.position.y < b.position.y
	
func check_dead_players():
	for i in range(player_num):
		if $Players.get_child(i).state == "dead" && not dead_players.has(i):
			players_score[i] = scores[0]
			dead_players.append(i)
			scores.remove(0)
	if dead_players.size() == (player_num - 1):
		game_over()

func create_score_ui():
	$CanvasLayer/Label.bbcode_text = "Scores" + "\n"
	for i in range(player_num):
		$CanvasLayer/Label.bbcode_text += "[color=" + available_colors[players[i].color] +"]"
		$CanvasLayer/Label.bbcode_text += "Player" + str(i + 1) + ": " +  str(players_score[i]) + "\n"
	$CanvasLayer/Label.visible = true

func game_over():
	if not game_over:
		$owlBear.game_over()
		game_over = true
		$theme.stop()

		$victory_fanfare.play()
		var final_score = 100
		var alive_players = player_num - dead_players.size()
		if alive_players > 1:
			final_score = 150
		final_score = final_score/alive_players
		for i in range(player_num):
			if $Players.get_child(i).state != "dead" && not dead_players.has(i):
				players_score[i] = final_score
		create_score_ui()
		$Timer2.start()

func on_timeout2():
	Party.end_game(players_score)

func _on_PreparationTimer_timeout():
	$prelude.stop()
	$theme.play()
