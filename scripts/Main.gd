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

onready var fade = $Loading/FadeToBlack

func load_lobby():
	load_world("res://scenes/Lobby.tscn")

func start_game():
	load_world("res://games/extinguish/index.tscn")

func load_world(scene_to_load: String):
	loading_world = scene_to_load
	
	ResourceQueue.queue_resource(loading_world)
	
	loading_state = LoadingStates.FADE_TO_BLACK_1
	fade.is_faded = true
	
	

func _ready():
	fade.connect("finished_fading", self, "on_finished_fading")
	ResourceQueue.start()
	
	load_world("res://scenes/Menu.tscn")

func on_finished_fading():
	match loading_state:
		LoadingStates.FADE_TO_BLACK_1:
			$World.visible = false
			if current_world:
				$World.remove_child(current_world)
				current_world.queue_free()
				current_world = null
			$Loading/ColorRect.visible = true 
			loading_state = LoadingStates.FADE_TO_LOADING
			fade.is_faded = false
		LoadingStates.FADE_TO_LOADING:
			loading_state = LoadingStates.LOADING
			set_process(true)
		LoadingStates.FADE_TO_BLACK_2:
			$Loading/ColorRect.visible = false
			$World.add_child(current_world)
			$World.visible = true
			loading_state = LoadingStates.FADE_TO_WORLD
			fade.is_faded = false
		LoadingStates.FADE_TO_WORLD:
			loading_state = LoadingStates.PLAYING
		_:
			pass

func _process(delta):
	if loading_state == LoadingStates.LOADING:
		print(ResourceQueue.get_progress(loading_world))
		if ResourceQueue.is_ready(loading_world):
			var new_world = ResourceQueue.get_resource(loading_world)
			current_world = new_world.instance()
			
			loading_state = LoadingStates.FADE_TO_BLACK_2
			fade.is_faded = true
			set_process(false)
