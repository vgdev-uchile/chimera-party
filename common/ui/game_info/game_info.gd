extends Control


@export var game_input_scene: PackedScene
@export var player_status_scene: PackedScene

@onready var image: TextureRect = %Image
@onready var title: Label = %Title
@onready var description: RichTextLabel = %Description
@onready var inputs_container: VBoxContainer = %InputsContainer
@onready var player_status_container: GridContainer = %PlayerStatusContainer
@onready var timer: Timer = $Timer


func _ready() -> void:
	var info = Game.get_current_game_info()
	if not info:
		Debug.log("No test_game_info info on Game autoload")
		return
	image.texture = info.image
	title.text = info.name
	description.text = info.description
	
	_fill_game_inputs()
	_fill_player_status()
	
	timer.timeout.connect(func(): Game.load_current_game())


func _fill_game_inputs() -> void:
	var info = Game.get_current_game_info()
	if not info or not game_input_scene:
		return
	for game_input in info.inputs:
		var game_input_inst = game_input_scene.instantiate()
		game_input_inst.setup(game_input)
		inputs_container.add_child(game_input_inst)


func _fill_player_status() -> void:
	if not player_status_scene:
		return
	for player in Game.players:
		var player_status_inst = player_status_scene.instantiate()
		player_status_container.add_child(player_status_inst)
		player_status_inst.setup(player)
		player_status_inst.status_changed.connect(_on_status_changed)


func _on_status_changed() -> void:
	var players_ready = true
	for player_status in player_status_container.get_children():
		players_ready = players_ready and player_status.is_ready
	if players_ready:
		timer.start()
	else:
		timer.stop()
