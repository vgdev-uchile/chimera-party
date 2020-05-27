extends Spatial

class_name Main

enum LoadingStates {
	FADE_TO_BLACK_1,
	FADE_TO_LOADING,
	LOADING,
	FADE_TO_BLACK_2,
	FADE_TO_WORLD,
	PLAYING
}

var loading_state = LoadingStates.PLAYING
var current_world = null
var loading_world = null

enum GameState {
	MENU,
	LOBBY,
	INTRO,
	GAME,
	SCORES,
	END
}

var game_state setget set_game_state

# {game, type}
var games = []
var game_weights = []


onready var fade = $Loading/Fade

func load_world(scene_to_load: String):
	loading_world = scene_to_load
	
	ResourceQueue.queue_resource(loading_world)
	
	loading_state = LoadingStates.FADE_TO_BLACK_1
	fade.fade_out()
	
	
func start_game():
	Party._new_game = true
	Party.current_round = 1
	set_game_state(GameState.MENU)
	load_games()

func _ready():
	fade.connect("finished_fading", self, "on_finished_fading")
	ResourceQueue.start()
	
	start_game()
	
func load_games():
	var directory: Directory = Directory.new()
	var error = directory.open("res://games/")
	if error == OK:
		directory.list_dir_begin(true)
		var game = directory.get_next()
		while game != "":
			if directory.current_is_dir():
				print(game + "/", "found")
				var config = load("res://games/"+game+"/Config.tres")
				if config.game_types & Party.GameType.ALL_FOR_ALL:
					games.append({"game": game, "type": Party.GameType.ALL_FOR_ALL})
				if config.game_types & Party.GameType.ONE_VS_TWO:
					games.append({"game": game, "type": Party.GameType.ONE_VS_TWO})
				if config.game_types & Party.GameType.ONE_VS_THREE:
					games.append({"game": game, "type": Party.GameType.ONE_VS_THREE})
				if config.game_types & Party.GameType.TWO_VS_TWO:
					games.append({"game": game, "type": Party.GameType.TWO_VS_TWO})
			else:
				print(game, " found. There shouldn't be a file here")
			game = directory.get_next()
	else:
		print("Error opening directory")

func filter_games():
	
	var players = 0
	for player in Party.get_players():
		if player.color != -1:
			players += 1
	
	var filtered_games = []
	
	for game in games:
		match game.type:
			Party.GameType.ALL_FOR_ALL:
				filtered_games.append(game)
			Party.GameType.ONE_VS_TWO:
				if players == 3:
					filtered_games.append(game)
			Party.GameType.ONE_VS_THREE, Party.GameType.TWO_VS_TWO:
				if players == 4:
					filtered_games.append(game)
	
	games = filtered_games
	
	var weight = 1.0 / games.size()
	for i in range(games.size()):
		game_weights.append(weight)

func choose_random_game():
	randomize()
#	Party._current_game = games[0].game
#	Party._make_groups()
	print("choose random")
	var target_weight = randf()
	var weight_sum = 0
	var new_game_index = -1
	for i in range(game_weights.size()):
		weight_sum += game_weights[i]
		if target_weight < weight_sum:
			new_game_index = i
			break
	if new_game_index != -1:
		Party._current_game = games[new_game_index].game
		Party.game_type = games[new_game_index].type
		# TODO Chage this when the groups are defined by other means
		Party._make_groups()
		var extracted_weight = game_weights[new_game_index] / 2
		game_weights[new_game_index] -= extracted_weight
		var extracted_weight_fraction = extracted_weight / game_weights.size()
		for i in range(game_weights.size()):
			game_weights[i] += extracted_weight_fraction
	else:
		print("No game found, this should never happened")


func on_finished_fading():
	$ColorRect.visible = false
	match loading_state:
		LoadingStates.FADE_TO_BLACK_1:
			$World.visible = false
			if current_world:
				$World.remove_child(current_world)
				current_world.queue_free()
				current_world = null
			$Loading/ColorRect.visible = true 
			loading_state = LoadingStates.FADE_TO_LOADING
			fade.fade_in()
		LoadingStates.FADE_TO_LOADING:
			loading_state = LoadingStates.LOADING
			set_process(true)
		LoadingStates.FADE_TO_BLACK_2:
			$Loading/ColorRect.visible = false
			$World.add_child(current_world)
			$World.visible = true
			loading_state = LoadingStates.FADE_TO_WORLD
			fade.fade_in()
		LoadingStates.FADE_TO_WORLD:
			loading_state = LoadingStates.PLAYING
		_:
			pass

func _process(delta):
	if loading_state == LoadingStates.LOADING:
#		print(ResourceQueue.get_progress(loading_world))
		if ResourceQueue.is_ready(loading_world):
			var new_world = ResourceQueue.get_resource(loading_world)
			current_world = new_world.instance()
			loading_state = LoadingStates.FADE_TO_BLACK_2
			if game_state == GameState.INTRO:
				if Party._new_game:
					Party._new_game = false
					filter_games()
				choose_random_game()
			fade.fade_out()
			set_process(false)

func next():
	match game_state:
		GameState.MENU:
			set_game_state(GameState.LOBBY)
		GameState.LOBBY:
			set_game_state(GameState.INTRO)
		GameState.INTRO:
			set_game_state(GameState.GAME)
		GameState.GAME:
			set_game_state(GameState.SCORES)
		GameState.SCORES:
			set_game_state(GameState.INTRO)

func set_game_state(new_state):
	game_state = new_state
	match game_state:
		GameState.MENU:
			load_world("res://scenes/Menu.tscn")
		GameState.LOBBY:
			load_world("res://scenes/Lobby.tscn")
		GameState.INTRO:
			load_world("res://scenes/Intro.tscn")
		GameState.GAME:
			load_world("res://games/"+ Party._current_game + "/index.tscn")
		GameState.SCORES:
			load_world("res://scenes/Scores.tscn")
