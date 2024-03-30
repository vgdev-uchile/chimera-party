extends Node2D

@export var player_scene: PackedScene
@export var file_grabber_scene: PackedScene
@export var files_scene: PackedScene

var _player_with_files: Chimerin = null

@onready var players: Node2D = $Players
@onready var spawns: Node2D = $Spawns
@onready var kill_timer: Timer = $KillTimer
@onready var score_timer: Timer = $ScoreTimer
@onready var score_container: VBoxContainer = %ScoreContainer


func _ready() -> void:
	if not player_scene:
		Debug.log("No player scene selected")
		return
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate() as Chimerin
		player_inst.global_position = spawns.get_child(i).global_position
		players.add_child(player_inst)
		player_inst.setup(player_data)
		
		var file_grabber_inst = file_grabber_scene.instantiate() as FileGrabber
		player_inst.add_child(file_grabber_inst)
		file_grabber_inst.files_taken.connect(_on_files_taken.bind(player_inst))
		
		var label = Label.new()
		label.text = "%s: %d" % [player_data.name, player_data.local_score]
		score_container.add_child(label)
	
	kill_timer.timeout.connect(_on_kill_timeout)
	score_timer.timeout.connect(_on_score_timeout)
	


func _process(delta: float) -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var label = score_container.get_child(i) as Label
		label.text = "%s: %d" % [player_data.name, player_data.local_score]
		score_container.add_child(label)


func _on_files_taken(player: Chimerin) -> void:
	_player_with_files = player
	kill_timer.start()
	score_timer.start()


func _on_kill_timeout() -> void:
	Debug.log("killed")
	score_timer.stop()
	var player = _player_with_files
	var file_grabber = FileGrabber.get_file_grabber(player)
	_player_with_files = null
	player.set_physics_process(false)
	file_grabber.has_files = false
	file_grabber.disable(true)
	_drop_files(player)
	await get_tree().create_timer(2).timeout
	player.set_physics_process(true)
	file_grabber.disable(false)


func _on_score_timeout() -> void:
	if _player_with_files:
		_player_with_files.data.local_score += 100


func _drop_files(player: Chimerin) -> void:
	var files_inst = files_scene.instantiate()
	files_inst.global_position = player.global_position + Vector2.DOWN.rotated(randf() * 2 * PI) * 150
	add_child(files_inst)
	move_child(files_inst, 1)
