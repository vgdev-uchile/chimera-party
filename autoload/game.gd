extends Control

signal player_color_changed(player)

@export var test: bool = false
@export var test_players: Array[PlayerResource] = []
@export var game_amount: int = 5
var players: Array[PlayerData] = []
var games: Array[String] = []
var current_game: String
var loading: bool = false
var _games_directory: String = "res://games/"
var _scene_to_load: String
var _games_remaining := 0
var _game_probability: Array[float] = []
@onready var animation_player: AnimationPlayer = $CanvasLayer/Fade/AnimationPlayer


func _ready() -> void:
	_games_remaining = game_amount
	
	set_process(false)
	
	var local_games_directory = "res://builds/games/"
	
	if OS.has_feature("template"):
		local_games_directory = OS.get_executable_path().get_base_dir() + "/games/"

	
	var dir = DirAccess.open(local_games_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				Debug.log("Found directory: " + file_name)
			else:
				Debug.log("Found file: " + file_name)
				var success = ProjectSettings.load_resource_pack(local_games_directory +  file_name, false)
				if success:
					games.append(file_name.split(".")[0])
				else:
					Debug.log("%s not loaded" % file_name)
			file_name = dir.get_next()
	else:
		Debug.log("An error occurred when trying to access the path")


func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(_scene_to_load)
	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			Debug.log("Invalid resource")
			_fade_in()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.THREAD_LOAD_FAILED:
			Debug.log("Load failed")
			_fade_in()
		ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_scene = ResourceLoader.load_threaded_get(_scene_to_load)
			get_tree().change_scene_to_packed(loaded_scene)
			_fade_in()


func get_current_game_info() -> GameInfo:
	return load(_games_directory + current_game + "/info.tres")

func load_scene(path):
	if loading:
		return
	_fade_out()
	_scene_to_load = path
	ResourceLoader.load_threaded_request(_scene_to_load)


func load_random_game():
	if _game_probability.is_empty():
		_game_probability.resize(games.size())
		_game_probability.fill(1)
	if is_last_level():
		return
	if games.is_empty():
		return
	
	var index = Statics.pick_by_weight(_game_probability)
	_game_probability[index] /= 4
	
	current_game = games[index]
	load_scene("res://ui/game_info.tscn")
	_games_remaining -= 1


func load_current_game():
	load_scene(_games_directory + current_game + "/main.tscn")


func end_game() -> void:
	load_scene("res://ui/results.tscn")


func game_over() -> void:
	_games_remaining = game_amount
	_game_probability.clear()
	Game.players.clear()
	load_scene("res://ui/main_menu.tscn")


func is_last_level() -> bool:
	return _games_remaining <= 0


func is_winner(player_data: PlayerData) -> bool:
	var winner_score = 0
	for player in Game.players:
		winner_score = max(winner_score, player.score)
	return player_data.score == winner_score


func play_sound(stream: AudioStream) -> void:
	var audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = stream
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)


func _fade_out() -> void:
	loading = true
	animation_player.play("fade_out")
	set_process(true)


func _fade_in() -> void:
	set_process(false)
	animation_player.play("fade_in")
	await animation_player.animation_finished
	loading = false
