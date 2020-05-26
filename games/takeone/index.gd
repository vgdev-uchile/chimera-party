extends Node2D

var Player = preload("res://games/takeone/Player.tscn")
var PriceFactory = preload("res://games/takeone/prices/PriceFactory.gd")


onready var Players = $Players
var players
var screen_size  # Size of the game window.
var started = false

var price_factory = PriceFactory.new()
var rng = RandomNumberGenerator.new()
export var price_spawn_chance = 0.1
export var max_angular_velocity_of_prices = 20

var final_scores

func _ready():
	price_factory._ready()
	
	screen_size = get_viewport_rect().size
	
#	Party.load_test()
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
	
	$Timer.connect("timeout", self, "on_timeout")
	$Timer2.connect("timeout", self, "on_timeout2")
	$StartTimer.connect("timeout", self, "start_game")

func start_game():
	started = true
	$Audio.get_node("BackgroundMusic").play()
	
	# Start Timer name update
	var start_timer_label = $CanvasLayer.get_node("StartTimerLabel")
	start_timer_label.visible = false
	
	$Timer.start()

func _process(delta):
	if started:
		if rng.randf() < price_spawn_chance:
			var x_start = 72.0/1920
			var x_end = 1320.0/1920
			
			var y_up = -50.0/1080
			
			var x_pos_spawn = (x_start + (x_end - x_start)*rng.randf())*screen_size.x 
			var y_pos_spawn = y_up*screen_size.y
			var w_spawn = (rng.randf() - 0.5)*2* max_angular_velocity_of_prices
			
			spawn_price(x_pos_spawn, y_pos_spawn, w_spawn)
		
		# Time Left Label
		var timer_label = $CanvasLayer.get_node("TimeLeftLabel")
		var time_left = int($Timer.time_left) + 1
		timer_label.text = str(time_left)
	
	# Start Timer name update
	var start_timer_label = $CanvasLayer.get_node("StartTimerLabel")
	var time_number_left = int($StartTimer.time_left) + 1
	var before_time = start_timer_label.text
	start_timer_label.text = str(time_number_left)
	
	if before_time != start_timer_label.text:
		if time_number_left > 1 && time_number_left < 5:
			$Audio/RedLight.play()
		elif time_number_left < 5:
			$Audio/GreenLight.play()

func on_timeout():
	$CanvasLayer/Label.visible = true
	
#	var final_scores = [0,0,0,0]
	final_scores = [0,0,0,0]
	for i in range(Players.get_children().size()):
		var player = Players.get_child(i)
		var max_price = player.get_max_price_in_basket()
		if max_price != null:
			final_scores[player.get_player_index()] = max_price.get_value()
	
	for player in $Players.get_children():
		player.set_physics_process(false)
	
#	Party.end_game(final_scores)
	$Timer2.start()
	
func on_timeout2():
	Party.end_game(final_scores)
	
func _physics_process(delta):
	var players = Players.get_children()
	players.sort_custom(self, "sort_by_y")
	for i in range(players.size()):
		players[i].z_index = i

func sort_by_y(a, b):
	return a.position.y < b.position.y
	
func spawn_price(x,y,w):
	var price = price_factory.get_random_price()
	price.position = Vector2(x, y)
	price.angular_velocity = w
	$Prices.add_child(price)
	


