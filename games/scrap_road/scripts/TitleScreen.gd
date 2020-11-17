extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var global_vars = get_node("/root/Global")
	var audio_manager = get_node("/root/AudioManager")
	
	for id in global_vars.get_players().keys():
		update_player_status(id)
	
	audio_manager.music_title_screen()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		self.start_game()
	
	if Input.is_action_just_pressed("player1_move_brake"):
		self.toggle_player_readyness(0)
	
	if Input.is_action_just_pressed("player2_move_brake"):
		self.toggle_player_readyness(1)
	
	if Input.is_action_just_pressed("player3_move_brake"):
		self.toggle_player_readyness(2)
	
	if Input.is_action_just_pressed("player4_move_brake"):
		self.toggle_player_readyness(3)

# toggle_player_readyness: int -> None
# Sets a player to ready if they are not and viceversa
func toggle_player_readyness(num):
	var global_vars = get_node("/root/Global")
	var audio_manager = get_node("/root/AudioManager")
	
	if (global_vars.get_players().keys().has(num)):
		global_vars.remove_player(num)
		audio_manager.sfx_back()
	else:
		global_vars.add_player(num)
		audio_manager.sfx_accept()
	
	update_player_status(num)
	
	var player_number = len(global_vars.get_players().keys())
	$PlayerRequirement.visible = (player_number < 2)
		
# update_player_status: int -> None
# Updates the player ready tick sprite
func update_player_status(num):
	var global_vars = get_node("/root/Global")
	var controlls_sprite = $Controlls.get_children()[num]
	controlls_sprite.get_child(1).visible = (global_vars.get_players().keys().has(num))

# start_game
# starts the game if there are enough players, does nothing otherwise
func start_game():
	var global_vars = get_node("/root/Global")
	var audio_manager = get_node("/root/AudioManager")
	
	var player_number = len(global_vars.get_players().keys())
	if player_number >= 2:
		audio_manager.sfx_accept()
		audio_manager.music_race()
		get_tree().change_scene("res://scenes/InfiniteMode.tscn")
	else:
		audio_manager.sfx_error()
		$PlayerRequirement.tremble()
