extends CanvasLayer

var taken_keyset = []
var taken_player = [false, false, false, false]
var players_ready = 0

enum State { WAITING, COUNT_DOWN, GO}
var current_state = State.WAITING

onready var player_selection = $Panel/PlayerSelection

func _ready():
	for i in range(4):
		release_slot(i)
		player_selection.get_child(i).connect("leave", self, "release_slot")
		player_selection.get_child(i).connect("player_ready", self, "on_player_ready")
		Party._add_player()
		

func _process(delta):
	if $AnimationPlayer.current_animation == "go":
		current_state = State.GO
	match current_state:
		State.WAITING:
			for i in range(4):
				if Input.is_action_just_pressed("keyset_" + str(i)) and not i in taken_keyset:
					assing_slot(i)
					taken_keyset.append(i)
		State.COUNT_DOWN:
				pass
		State.GO:
			for ps in player_selection.get_children():
				ps.go()
				set_process(false)
			Party._next()

func action_add_key(action, player_index: int, key):
	var ike: InputEventKey
	ike = InputEventKey.new()
	ike.scancode = key
	InputMap.action_add_event(action + str(player_index), ike)

func assing_slot(keyset_index: int):
	var player_index = -1
	for i in range(4):
		if not taken_player[i]:
			player_index = i
			taken_player[i] = true
			break
	if player_index != -1:
		match keyset_index:
			0:
				action_add_key("move_left_", player_index, KEY_A)
				action_add_key("move_right_", player_index, KEY_D)
				action_add_key("move_up_", player_index, KEY_W)
				action_add_key("move_down_", player_index, KEY_S)
				action_add_key("action_a_", player_index, KEY_B)
				action_add_key("action_b_", player_index, KEY_N)
			1:
				action_add_key("move_left_", player_index, KEY_F)
				action_add_key("move_right_", player_index, KEY_H)
				action_add_key("move_up_", player_index, KEY_T)
				action_add_key("move_down_", player_index, KEY_G)
				action_add_key("action_a_", player_index, KEY_M)
				action_add_key("action_b_", player_index, KEY_COMMA)
			2:
				action_add_key("move_left_", player_index, KEY_J)
				action_add_key("move_right_", player_index, KEY_L)
				action_add_key("move_up_", player_index, KEY_I)
				action_add_key("move_down_", player_index, KEY_K)
				action_add_key("action_a_", player_index, KEY_Z)
				action_add_key("action_b_", player_index, KEY_X)
			3:
				action_add_key("move_left_", player_index, KEY_LEFT)
				action_add_key("move_right_", player_index, KEY_RIGHT)
				action_add_key("move_up_", player_index, KEY_UP)
				action_add_key("move_down_", player_index, KEY_DOWN)
				action_add_key("action_a_", player_index, KEY_C)
				action_add_key("action_b_", player_index, KEY_V)
		player_selection.get_child(player_index).init(keyset_index, player_index)
		for i in range(4):
			player_selection.get_child(i).set_available_keyset(false, keyset_index)

func release_slot(player_index: int):
	var spi = str(player_index)
	InputMap.action_erase_events("move_left_" + spi)
	InputMap.action_erase_events("move_right_" + spi)
	InputMap.action_erase_events("move_up_" + spi)
	InputMap.action_erase_events("move_down_" + spi)
	InputMap.action_erase_events("action_a_" + spi)
	InputMap.action_erase_events("action_b_" + spi)
	var keyset_index = player_selection.get_child(player_index).get_keyset_index()
	taken_keyset.erase(keyset_index)
	if keyset_index >= 0:
		for i in range(4):
			player_selection.get_child(i).set_available_keyset(true, keyset_index)
	taken_player[player_index] = false

func on_player_ready(player_index, value):
	if value:
		players_ready += 1
	else:
		players_ready -= 1
		if $AnimationPlayer.current_animation == "count_down":
			$AnimationPlayer.play("waiting")
			current_state = State.WAITING
	var total_players = 0
	for taken in taken_player:
		if taken:
			total_players += 1
	if total_players > 1 and total_players == players_ready:
		$AnimationPlayer.play("count_down")
		current_state = State.COUNT_DOWN
