extends CanvasLayer

var PlayerScore = preload("res://scenes/PlayerScore.tscn")

onready var Players = $Panel/Screen/Center/Players
var players = []

var final_round = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", self, "on_timeout")
	$Timer2.connect("timeout", Party, "_game_over")
	
	for i in range(Party.get_players().size()):
		var player = Party._players[i]
		if player.color != -1:
			var player_score = PlayerScore.instance()
			player_score.dino_color = player.color
			player_score.score = player.points
			players.append({"player_score": player_score, "index": i})

	players.sort_custom(self, "score_sort")

	for player in players:
		Players.add_child(player.player_score)
	
	if Party.current_round == Party.rounds:
		$Panel/Screen/Round.text = "Ronda Final"
		final_round = true
	else:
		$Panel/Screen/Round.text = "Ronda " + str(Party.current_round)
		Party.current_round += 1
	$Timer.start()
	
func score_sort(a, b):
	return a.player_score.score > b.player_score.score

func on_timeout():
	if final_round:
		var winners = []
		var max_score = 0
		for player in players:
			if int(player.player_score.score) >= max_score:
				max_score = int(player.player_score.score)
				winners.append(player)
		
		if winners.size() == 1:
			$Panel/Screen/Round.text = "Gana P" + str(winners[0].index + 1)
			$Panel/Screen/Round.modulate = Party.available_colors[winners[0].player_score.dino_color]
		else:
			$Panel/Screen/Round.text = "Empate · o ·)>"
			$Panel/Screen/Round.modulate = Color("#ff7315")
		$Timer2.start()
	else:
		Party._next()
