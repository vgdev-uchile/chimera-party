extends Node2D

var Player = preload("res://games/n-pong/Player.tscn")

onready var ball = $Ball
onready var center = get_viewport_rect().size / 2
onready var Players = $Players
var players
var radius = 400
var player_num
var game_finished = false
var scores

func _ready():
	$Field.scene = self
	$Field.position = center
	$Field.radius = radius
	
	$Lives.field = $Field
		
#	Party.load_test()
	players = Party.get_players()
	for i in range(players.size()):
		if players[i].color != -1:
			var player_inst = Player.instance()
			player_inst.scene = self
			player_inst.field = $Field
			$Players.add_child(player_inst)
			player_inst.init(i, players[i].color)
	
	player_num = Players.get_child_count()
	for i in range(player_num):
		var player = Players.get_child(i)
		player.seq_number = i
		player.start()
		
	$CanvasLayer/Label.visible = true
	
	$StartMovingTimer.connect("timeout", self, "on_start_moving_timeout")
	$HideCountdownTimer.connect("timeout", self, "on_hide_countdown_timeout")
	$Timer.connect("timeout", self, "on_timeout")


func on_start_moving_timeout():
	ball.start_moving()	
	$HideCountdownTimer.start()
	
	
func on_hide_countdown_timeout():
	$CanvasLayer/Label.visible = false
	
func score(lives, max_lives):
	return floor(lives / max_lives * 100)
	
	
func finish_game():
	var max_lives = 0
	var active_players = Players.get_children()
	for player in active_players:
		max_lives = max(max_lives, player.lives)
		
	scores = [0, 0, 0, 0]
	for player in active_players:
		scores[player.player_index] = score(player.lives, max_lives)
	
	game_finished = true
	$Timer.start()

func on_timeout():
	Party.end_game(scores) 

func _physics_process(delta):
	var players = Players.get_children()
	players.sort_custom(self, "sort_by_y")
	for i in range(players.size()):
		players[i].z_index = i
		
	if $Ball.position.distance_to(center) > radius + 8 * $Ball.radius:
		var victim = $Field.player_at(ball.angle())
		var victim_died = victim.lose_life()
		if victim_died:
			$Ball.reset()
			finish_game()
			$CanvasLayer/Label.visible = true
		else:
			$Ball.reset()
			$StartMovingTimer.start()
			$CanvasLayer/Label.visible = true
		
		
func _process(delta):	
	var countdown = ceil($StartMovingTimer.get_time_left())
	$CanvasLayer/Label.text = str(countdown)
	
	if game_finished:
		$CanvasLayer/Label.text = "Terminó"


func sort_by_y(a, b):
	return a.position.y < b.position.y
