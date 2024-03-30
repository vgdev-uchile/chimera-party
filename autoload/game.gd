extends Control


@export var test: bool = false
@export var test_players: Array[PlayerResource] = []

var players: Array[Statics.PlayerData] = []
var games: Array[String] = []
var current_game: String

var _games_directory: String = "res://games/"
var _scene_to_load: String
@onready var animation_player: AnimationPlayer = $CanvasLayer/Fade/AnimationPlayer


func _ready() -> void:
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
			animation_player.play("fade_in")
			set_process(false)
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.THREAD_LOAD_FAILED:
			Debug.log("Load failed")
			animation_player.play("fade_in")
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_scene = ResourceLoader.load_threaded_get(_scene_to_load)
			get_tree().change_scene_to_packed(loaded_scene)
			animation_player.play("fade_in")
			set_process(false)


func get_current_game_info() -> GameInfo:
	return load(_games_directory + current_game + "/info.tres")

func load_scene(path):
	_scene_to_load = path
	animation_player.play("fade_out")
	ResourceLoader.load_threaded_request(_scene_to_load)
	set_process(true)


func load_random_game():
	current_game = games[randi() % games.size()]
	load_scene("res://ui/game_info.tscn")


func load_current_game():
	load_scene(_games_directory + current_game + "/main.tscn")


func end_game() -> void:
	Game.players.clear()
	load_scene("res://ui/main_menu.tscn")
