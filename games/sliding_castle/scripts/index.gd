extends Spatial

#var Player = preload("res://bounce/scenes/Player.tscn")

onready var Players = $Players
#var players 
onready var players = Party.get_players()

var winner

# Called when the node enters the scene tree for the first time.
func _ready():
#	Party.load_test()
#	players = Party.get_players()
	var master_tokens = $Master/Tokens
	var shuffle_array = $Master.generate_shuffle_array()
	var shuffle_signal = false
	for i in range(players.size()):
		if players[i].color != -1:
			if not shuffle_signal:
				shuffle_signal = true
				$Players.get_child(i).connect("shuffle_finished", self, "on_shuffle_finished")
			$Players.get_child(i).connect("completed", self, "on_completed")
			$Ground.get_child(i).get_surface_material(0).albedo_color = \
				Party.available_colors[players[i].color]
			$Players.get_child(i).init(i, master_tokens, shuffle_array.duplicate(true))
			
	$Timer.connect("timeout", self, "end_game")
	

func on_shuffle_finished():
	$CanvasLayer/Finish.text = "Vamos!"
	$AnimationPlayer.play("hide")

func on_completed(player_index):
	if winner == null:
		for i in range(players.size()):
			if players[i].color != -1:
				$Players.get_child(i).is_shuffle_finished = false
		winner = player_index
		$Timer.start()
		$CanvasLayer/Finish.text = "Gana P" + str(player_index + 1) + " +100"
		$CanvasLayer/Finish.modulate = Party.available_colors[player_index]

func end_game():
	var points = [0, 0, 0, 0]
	points[winner] = 100
	Party.end_game(points)
