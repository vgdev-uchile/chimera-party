extends Node2D

@export var player_scene: PackedScene

var target_scene = preload("res://scenes/target.tscn")
var _lobby = {} # {PlayerData: LobbyData}
var _splat_sfx = preload("res://assets/sfx/splat.mp3")

@onready var players: Node2D = $Players
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var shake_camera: Camera2D = $ShakeCamera
@onready var ready_area: Area2D = $ReadyArea


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
			player_data.input = test_player.input
			player_data.primary_color = test_player.color
			Game.players.append(player_data)
		Game.load_random_game()
		return
	Game.player_color_changed.connect(_on_player_color_changed)
	ready_area.player_ready.connect(_on_player_ready)
	ready_area.game_ready.connect(func(): Game.load_random_game())


func _input(event: InputEvent) -> void:
	for i in 8:
		var action = "check_player_%d" % i
		if InputMap.has_action(action) && event.is_action_pressed(action):
			_check_player(i)


func _exit_tree() -> void:
	for i in 8:
		var action = "check_player_%d" % i
		if InputMap.has_action(action):
			InputMap.erase_action(action)


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
	players.add_child(player_inst)
	player_inst.setup(player_data)
	
	var lobby_data = LobbyData.new()
	lobby_data.player = player_inst
	_lobby[player_data] = lobby_data
	
	_reset_player(player_inst)
	
func _reset_player(player: Chimerin) -> void:
	player.disable(true)
	player.global_position = Vector2(player_spawn.global_position.x, -100) + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var tween = player.create_tween()
	tween.tween_property(player, "global_position", player.global_position + Vector2.DOWN * player_spawn.global_position.y, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(Game.play_sound.bind(_splat_sfx))
	tween.tween_callback(shake_camera.shake.bind(50))
	tween.tween_callback(player.disable.bind(false))
	
	
	

func _on_player_color_changed(player: Statics.PlayerData) -> void:
	var lobby_data = _lobby[player]
	lobby_data.remove_target()
	lobby_data.has_color = true
	
	# check if there is others players of the same color not target
	for other_player in Game.players:
		if other_player.input == player.input:
			continue
		if other_player.primary_color == player.primary_color:
			var other_lobby_data = _lobby[other_player]
			var target = other_lobby_data.add_target(target_scene)
			if target:
				target.fired.connect(_on_player_fired.bind(other_player))


func _on_player_fired(player: Statics.PlayerData) -> void:
	Game.players.erase(player)
	shake_camera.shake()
	var chimerin = _lobby[player].player as Chimerin
	var target = _lobby[player].target
	_lobby.erase(player)
	chimerin.disable(true, false)
	target.reparent(self)
	var tween = chimerin.create_tween()
	tween.tween_property(chimerin, "rotation", randf_range(PI / 4, PI / 2) * (randi() % 2 * 2 - 1), 0.2)
	tween.tween_property(chimerin, "modulate:a", 0, 1)


func _on_player_ready(player: Statics.PlayerData, value: bool) -> void:
	if not _lobby.has(player):
		return
	var lobby_data = _lobby[player]
	lobby_data.is_ready = value
	
	_check_game_ready()


func _check_game_ready() -> void:
	var game_ready = true
	for lobby_data in _lobby.values():
		if not lobby_data.has_color or not lobby_data.is_ready:
			game_ready = false
			break
	ready_area.enable(game_ready)


class LobbyData:
	var player: Chimerin = null
	var target: Node2D = null
	var has_color: bool = false
	var is_ready: bool = false
	
	func remove_target():
		if is_instance_valid(target):
			target.queue_free()
	
	func add_target(target_scene: PackedScene) -> Node2D:
		if is_instance_valid(target) or not player:
			return null
		target = target_scene.instantiate()
		player.add_child(target)
		has_color = false
		return target
	


