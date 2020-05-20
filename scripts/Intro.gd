extends CanvasLayer


var PlayerControl = preload("res://scenes/PlayerControl.tscn")
var Dino = preload("res://scenes/Dino.tscn")

enum Direction {
	left = 1,
	right = 2,
	up = 4,
	down = 8
}

enum Action {
	a = 1,
	b = 2
}

onready var Players = $Panel/Preview/Players

#[{player, dino}]
var player_dinos = []
var players_ready = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	
	var game = Party._current_game
	var type = Party.game_type
	var config = load("res://games/" + game + "/Config.tres") as Config
	var image = load("res://games/" + game + "/intro.png")
	
	$Panel/Preview.texture = image
	
	$DisplayName.text = config.display_name
	$Description.text = config.description
	
	var input_groups = config.dir_group_4 != 0 or config.act_group_2 != 0
	
	if input_groups:
		if config.control_group:
			$Controls/Group1.text = config.cg_name_0
			$Controls/Group2.text = config.cg_name_1
		$Controls/Group1.visible = true
		$Controls/Group2.visible = true
	
	var group1_pointer = $Controls/Group1
	var group2_pointer = $Controls/Group2
	
	var node_pointer = group1_pointer
	
	for i in range(8):
		var dir_group = config.get("dir_group_" + str(i))
		if dir_group != 0:
			var player_control = PlayerControl.instance()
			player_control.description = config.get("dir_desc_" + str(i))
			player_control.left = bool(dir_group & Direction.left)
			player_control.right = bool(dir_group & Direction.right)
			player_control.up = bool(dir_group & Direction.up)
			player_control.down = bool(dir_group & Direction.down)
			$Controls.add_child_below_node(node_pointer, player_control)
			node_pointer = player_control
		if i == 3:
			group1_pointer = node_pointer
			node_pointer = group2_pointer
	group2_pointer = node_pointer
	
	node_pointer = group1_pointer
	
	for i in range(4):
		var act_group = config.get("act_group_" + str(i))
		if act_group != 0:
			var player_control = PlayerControl.instance()
			player_control.description = config.get("act_desc_" + str(i))
			player_control.a = bool(act_group & Action.a)
			player_control.b = bool(act_group & Action.b)
			$Controls.add_child_below_node(node_pointer, player_control)
			node_pointer = player_control
		if i == 1:
			node_pointer = group2_pointer
	
	# groups
	
	
	Players.get_node("VS").visible = Party.groups.size() > 1
	
	for i in range(Party.groups.size()):
		for player in Party.groups[i]:
			var dino = Dino.instance()
			dino.dino_color = Party.get_players()[player].color
			Players.add_child(dino)
			player_dinos.append({"player": player, "dino": dino})
		if i == 0:
			Players.move_child(Players.get_node("VS"), Players.get_child_count() - 1)
	
	$Timer.connect("timeout", self, "on_timeout")

func on_timeout():
	Party._next()

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	for player_dino in player_dinos:
		if event.is_action_pressed("action_a_" + str(player_dino.player)) and just_pressed:
			player_dino.dino.ok = !player_dino.dino.ok
			if player_dino.dino.ok:
				players_ready += 1
			else:
				players_ready -= 1
			if players_ready == player_dinos.size():
				$Timer.start()
			else:
				$Timer.stop()
