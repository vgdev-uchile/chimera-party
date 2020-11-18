extends Node2D
const car_factory = preload("res://scenes/Car.tscn")


# Declare member variables here. Examples:
const player_positions = [Vector2(350, 400), Vector2(450, 400), Vector2(250, 400), Vector2(550, 400)]
var game_over = false
var waiting = false


# Called when the node enters the scene tree for the first time.
func _ready():
	var global_vars = get_node("/root/Global")
	var players = global_vars.get_players()
	var players_keys = players.keys()
	
	for i in range(len(players_keys)):
		var key = players_keys[i]
		var player_id = players[i].get_player_id()
		var car = car_factory.instance()
		car.set_color(players[i].get_player_color())
		car.set_input_prefix("player" + str(player_id + 1))
		car.set_player_name("player " + str(player_id + 1))
		car.position = player_positions[i]
		$Players.add_child(car)
	
	self.game_over = true
	self.waiting = true
	$ForegroundElements/Control/CountLabel.visible = true
	$ResetTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var audio_manager = get_node("/root/AudioManager")
	if game_over and (not waiting):
		if Input.is_action_just_pressed("ui_accept"):
			audio_manager.sfx_accept()
			
			# Hides Winner Screen
			var winner_screen = $ForegroundElements/Control/WinnerScreen
			winner_screen.visible = false
			
			$ForegroundElements/Control/CountLabel.visible = true
			$ResetTimer.start()
			
			self.waiting = true
	elif game_over and waiting:
		var number_to_print = stepify($ResetTimer.time_left,1)
		if number_to_print == 0:
			$ForegroundElements/Control/CountLabel.text = "GO!"
		else:
			$ForegroundElements/Control/CountLabel.text = str(stepify($ResetTimer.time_left,1))

# get_players: None -> Array(Car)
# gets the player's cars
func get_players():
	var players = Array()
	for child in $Players.get_children():	
		players.append(child)
	
	return players

# reset
# resets the level
func reset():
	# Resets the Debris
	$BoxSpawner.reset() 
	
	# Resets Player Positions
	var players = $Players.get_children()
	for i in range(len(players)):
		var player = players[i]
		player.position = player_positions[i]
	
	# Restarts Timer
	$ForegroundElements/Control/Timer/Timer.start()
	
	# Sets game over var to false
	$BoxSpawner.set_active(true)
	self.game_over = false

# announce_victory: Car -> None
# announces the victory of the first player
func announce_victory(winner):
	var winner_screen = $ForegroundElements/Control/WinnerScreen
	var winner_label = $ForegroundElements/Control/WinnerScreen/WinnerString
	winner_screen.visible = true
	winner_label.text = "THE WINNER IS\n" + winner.get_name()
	
	$BoxSpawner.set_active(false)
	game_over = true

# _on_Timer_timeout
# Handler of the signal to where the timer gets to 0
func _on_Timer_timeout():
	var players = self.get_players()
	var winner = players[0]
	for player in players:
		if player.position.y < winner.position.y:
			winner = player
	self.announce_victory(winner)


func _on_ResetTimer_timeout():
	$ForegroundElements/Control/CountLabel.visible = false
	self.reset()
	self.waiting = false
