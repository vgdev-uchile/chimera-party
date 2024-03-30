extends Control


@export var test: bool = false
@export var test_players: Array[PlayerResource] = []
@export var test_game_path: String = "res://scenes/test.tscn"

var players: Array[Statics.PlayerData] = []

var _game_to_load: String
@onready var animation_player: AnimationPlayer = $CanvasLayer/Fade/AnimationPlayer


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(_game_to_load)
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
			var loaded_game = ResourceLoader.load_threaded_get(_game_to_load)
			get_tree().change_scene_to_packed(loaded_game)
			animation_player.play("fade_in")
			set_process(false)


func load_game(path):
	_game_to_load = path
	animation_player.play("fade_out")
	ResourceLoader.load_threaded_request(_game_to_load)
	set_process(true)
