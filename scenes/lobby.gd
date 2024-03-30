extends Node2D

@export var player_scene: PackedScene

@onready var players: Node2D = $Players
@onready var player_spawn: Marker2D = $PlayerSpawn


func _enter_tree() -> void:
	for i in 8:
		var action = "check_player_%d" % i
		InputMap.add_action(action)
		var events = []
		events.append_array(InputMap.action_get_events("move_left_%d" % i))
		events.append_array(InputMap.action_get_events("move_right_%d" % i))
		events.append_array(InputMap.action_get_events("move_up_%d" % i))
		events.append_array(InputMap.action_get_events("move_down_%d" % i))
		for event in events:
			InputMap.action_add_event(action, event)


func _ready() -> void:
	if Game.test:
		for test_player in Game.test_players:
			var player_data = Statics.PlayerData.new()
			player_data.name = test_player.name
			player_data.input = test_player.input
			player_data.primary_color = test_player.color
			Game.players.append(player_data)
		Game.load_random_game()


func _exit_tree() -> void:
	for i in 8:
		var action = "check_player_%d" % i
		if InputMap.has_action(action):
			InputMap.erase_action(action)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().reload_current_scene()
		Game.players = []
	if Input.is_action_just_pressed("start"):
		Game.load_random_game()
	for i in 8:
		var action = "check_player_%d" % i
		if InputMap.has_action(action) && event.is_action_pressed(action):
			_check_player(i)


func _check_player(player_input: int) -> void:
	for player in Game.players:
		if player.input == player_input:
			return
	_create_player(player_input)


func _create_player(player_input: int) -> void:
	if not player_scene:
		Debug.log("No player scene selected")
		return
	var player_data = Statics.PlayerData.new()
	player_data.input = player_input
	Game.players.append(player_data)
	var player_inst = player_scene.instantiate()
	player_inst.setup(player_data)
	player_inst.global_position = player_spawn.global_position
	players.add_child(player_inst)
	
