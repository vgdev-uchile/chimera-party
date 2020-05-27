extends Node

var rng = RandomNumberGenerator.new()
var scores = {"Verde": 0, "Rojo": 0, "Amarillo": 0, "Azul": 0}
var color_names = ["Verde", "Rojo", "Amarillo", "Azul", "Blanco"]
var available_colors = [Color("00ff00"), Color("ff0000"), Color("ffff00"), Color("0000ff")]
var possible_colors = [4]

var color_order = []

export var game_length = 30
var time = 0

var Players
var Player = load("res://games/MothFight/Moth.tscn")
var Counter = load("res://games/MothFight/ScorePanel.tscn")

class ScoreSorter:
	static func sort_scores(a, b):
		return a[1] > b[1]

func _ready():
	rng.randomize()
	time = game_length
	get_node("../CanvasLayer/TimerLabel").parse_bbcode("[center]{mins}:{secs}[/center]".format({"mins": time/60, "secs": "%02d" % (time % 60)}))
	Players = get_node("../Players")
	#Party.load_test()
	var players = Party.get_players()
	for i in range(players.size()):
		if players[i].color != -1:
			var player_inst = Player.instance()
			Players.add_child(player_inst)
			player_inst.init(i, players[i].color)
			possible_colors.append(players[i].color)
			var counter = Counter.instance()
			counter.set_color(color_names[player_inst.player_color])
			counter.get_node("Panel/Bg").modulate = available_colors[player_inst.player_color]
			var score_container = get_node("../CanvasLayer/HBoxContainer")
			score_container.add_child(counter)
			player_inst.score_counter = counter
	var player_num = Players.get_child_count()
	for i in possible_colors:
		for _j in range(5):
			color_order.append(i)
	for _i in range(45 - 5 * possible_colors.size()):
		color_order.append(4)
	color_order.shuffle()
	for i in range(player_num):
		Players.get_child(i).global_position = \
			get_node("../Positions").get_child(i).global_position
	get_node("../CanvasLayer/CountDownLabel/AnimationPlayer").play("countdown")
	yield(get_node("../CanvasLayer/CountDownLabel/AnimationPlayer"), "animation_finished")
	start_game()

func activate_lightbulb(n):
	var col = color_order.pop_back()
	var light = $Lights.get_child(n)
	light.color = col
	light.switch(true)

func lights_on():
	var c = 0
	for lamp in $Lights.get_children():
		if lamp.on:
			c += 1
	return c
	
func add_score(moth, light_col):
	if light_col == 4:
		scores[color_names[moth.player_color]] += 1
		moth.score_counter.add_score(1)
	elif moth.player_color == light_col:
		scores[color_names[moth.player_color]] += 2
		moth.score_counter.add_score(2)
	else:
		scores[color_names[moth.player_color]] += 1
		moth.score_counter.add_score(1)
		scores[color_names[light_col]] -= 1
		for child in get_node("../CanvasLayer/HBoxContainer").get_children():
			if child.color_name == color_names[light_col]:
				child.add_score(-1)

func final_score():
	var lamps = [[0, 0], [1, 0], [2, 0], [3, 0]]
	var final_scores = [0, 0, 0, 0]
	
	for moth in Players.get_children():
		lamps[moth.player_index] = [moth.player_index, moth.get_score()]
	
	lamps.sort_custom(ScoreSorter, "sort_scores")
	
	var lamp_scores = []
	for l in lamps:
		lamp_scores.append(l[1])
	if lamp_scores.max() > 0:
		var i = 0
		while i < 4:
			var tier = i
			var max_score = lamp_scores.max()
			var players_in_tier = lamp_scores.count(max_score)
			while max_score in lamp_scores:
				lamp_scores.erase(max_score)
			var tier_score = (100 - 25 * tier - 25 * (players_in_tier - 1)) if lamps[i][1] > 0 else 0
			
			for _j in range(players_in_tier):
				final_scores[lamps[i][0]] = tier_score
				for moth in get_node("../Players").get_children():
					if moth.player_index == lamps[i][0]:
						var tier_texture
						if tier_score > 0:
							match tier:
								0:
									tier_texture = load("res://games/MothFight/Sprites/crown.png")
								1:
									tier_texture = load("res://games/MothFight/Sprites/silver_bulb.png")
								2:
									tier_texture = load("res://games/MothFight/Sprites/bronze_bulb.png")
								3:
									tier_texture = load("res://games/MothFight/Sprites/broken_bulb.png")
						else:
							tier_texture = load("res://games/MothFight/Sprites/broken_bulb.png")
						moth.score_counter.get_node("Panel/TierSprite").texture = tier_texture
						moth.score_counter.get_node("Panel/TierSprite/RichTextLabel").parse_bbcode(
							"[center][color=#{color}]+{score}[/color][/center]".format(
								{"score": tier_score,
								"color": available_colors[moth.player_color].to_html(false)}))
				i += 1
	return final_scores

func start_game():
	$GameOverTimer.start(1)
	$Timer.start(2)
	$AudioStreamPlayer.play()

func start_timer():
	if $Timer.is_stopped():
		$Timer.start(4)

func _on_Timer_timeout():
	if lights_on() <3:
		var is_off = false
		var next
		while not is_off:
			next = rng.randi_range(0, $Lights.get_child_count()-1)
			if not $Lights.get_child(next).on:
				is_off = true
		activate_lightbulb(next)
	start_timer()

func _on_GameOverTimer_timeout():
	time -= 1
	get_node("../CanvasLayer/TimerLabel").parse_bbcode("[center]{mins}:{secs}[/center]".format({"mins": time/60, "secs": "%02d" % (time % 60)}))
	if time == 0:
		$GameOverTimer.stop()
		get_node("../CanvasLayer/TextureRect").visible = true
		$Timer.stop()
		for child in $Lights.get_children():
			child.switch(false)
		var s = final_score()
		for panel in get_node("../CanvasLayer/HBoxContainer").get_children():
			panel.get_node("Panel/TierSprite").visible = true
		$EndGameTimer.start(7)
		yield($EndGameTimer, "timeout")
		Party.end_game(s)
