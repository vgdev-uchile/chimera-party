tool

extends Spatial

var player_index
var player_color

# Inputs
var move_left = ""
var move_right = ""
var move_up = ""
var move_down = ""
var action_a = ""
var action_b = ""

export var is_master: bool = false

var BoardTile = preload("res://games/sliding_castle/scenes/BoardTile.tscn")

export var board_size : int = 4 setget set_board_size
export var build : bool = false setget set_build
onready var cursor_coords = Vector2(board_size - 1, board_size - 1)

onready var Tokens = $Tokens
#onready var Dummy = $Tokens/Dummy
var Dummy

onready var Board = $Board

var tokens_folder = "res://games/sliding_castle/models/Tower Defense Kit (1.0)/Models/Tokens/"
var Towers = []
var Tiles = []
var Paths = {"straights": [], "corners": [], "ends": [], "splits": [], "crossings": []}

var board = []
var solution_board = []
var shuffle_array = []

var tween_timer = 0.25

var is_shuffle_finished = false

signal shuffle_finished

signal completed

# 3: ╝ 2: ╚ 
# 0: ╗ 1: ╔ 
var availble_corners = [0, 0, 0, 0]

# 0: ║ 1: ═
var availble_straights = [0, 0]

var tile_type = 1
var tile_types = 2

var available_corner_tokens = [[],[],[],[]]
var available_straight_tokens = [[],[]]
var available_tower_tokens = []
var available_tile_tokens = []

func set_build(new_value):
	build = new_value
	if build:
		generate_tokens()

func set_board_size(new_value):
	board_size = new_value
	update_board()
	reset_available()
	generate_tokens()
	
func _ready():
	randomize()
	tile_type = randi() % tile_types
	update_board()
	if is_master:
		load_tokens()
		generate_tokens()
	else:
		$Timer.connect("timeout", self, "shuffle_one")

func load_tokens():
	load_towers()
	load_tiles()
	load_paths()
	reset_available()

func reset_available():
	available_tower_tokens = []
	for i in range(Towers.size()):
			available_tower_tokens.append(i)
	available_tile_tokens = []
	for i in range(Tiles.size() / tile_types):
			available_tile_tokens.append(i)
	available_corner_tokens = [[],[],[],[]]
	for i in range(Paths.corners.size() / tile_types):
		for j in range(available_corner_tokens.size()):
			available_corner_tokens[j].append(i)
	available_straight_tokens = [[],[]]
	for i in range(Paths.straights.size() / tile_types):
		for j in range(available_straight_tokens.size()):
			available_straight_tokens[j].append(i)
	
func load_towers():
	var directory: Directory = Directory.new()
	var error = directory.open(tokens_folder + "Towers/")
	if error == OK:
		directory.list_dir_begin(true)
		var tower = directory.get_next()
		while tower != "":
			if not directory.current_is_dir():
#				print(tower + " found")
				Towers.append(load(tokens_folder + "Towers/" + tower))
			else:
				print(tower, "/ found. There shouldn't be a folder here")
			tower = directory.get_next()
	else:
		print("Error opening directory")
	


func load_tiles():
	var directory: Directory = Directory.new()
	var error = directory.open(tokens_folder + "Tiles/")
	if error == OK:
		directory.list_dir_begin(true)
		var tile = directory.get_next()
		while tile != "":
			if not directory.current_is_dir():
#				print(tile + " found")
				Tiles.append(load(tokens_folder + "Tiles/" + tile))
			else:
				print(tile, "/ found. There shouldn't be a folder here")
			tile = directory.get_next()
	else:
		print("Error opening directory")
		


func load_paths():
	for type in ["straights", "corners", "ends", "splits", "crossings"]:	
		var directory: Directory = Directory.new()
		var error = directory.open(tokens_folder + "Paths/" + type + "/")
		if error == OK:
			directory.list_dir_begin(true)
			var path = directory.get_next()
			while path != "":
				if not directory.current_is_dir():
#					print(path + " found")
					Paths[type].append(load(tokens_folder + "Paths/" + type + "/" + path))
				else:
					print(path, "/ found. There shouldn't be a folder here")
				path = directory.get_next()
		else:
			print("Error opening directory")

func update_board():
	board = []
	for i in range(board_size):
		var row = []
		for j in range(board_size):
			row.append("o")
		board.append(row)
	board[board_size - 1][board_size - 1] = "p"
	randomize()
	if Board:
		for child in Board.get_children():
			child.queue_free()
		var base = BoardTile.instance()
		Board.add_child(base) 
		base.mesh.size = Vector3(board_size + 2, 0.2, board_size + 2)
		base.transform.origin = Vector3(0.0, -0.1, 0.0)
		for i in range(board_size + 2):
			var board_tile_top = BoardTile.instance()
			Board.add_child(board_tile_top)
			board_tile_top.transform.origin = Vector3((board_size + 1.0) / 2.0, 0.1, i - (board_size + 1.0) / 2.0)
			var board_tile_bottom = BoardTile.instance()
			Board.add_child(board_tile_bottom)
			board_tile_bottom.transform.origin = Vector3(-(board_size + 1.0) / 2.0, 0.1, i - (board_size + 1.0) / 2.0)
		for i in range(board_size):
			var board_tile_left = BoardTile.instance()
			Board.add_child(board_tile_left)
			board_tile_left.transform.origin = Vector3(i + 1 - (board_size + 1.0) / 2.0, 0.1, -(board_size + 1.0) / 2.0)
			var board_tile_right = BoardTile.instance()
			Board.add_child(board_tile_right)
			board_tile_right.transform.origin = Vector3(i + 1 - (board_size + 1.0) / 2.0, 0.1, (board_size + 1.0) / 2.0)


func generate_tokens():
	for child in Tokens.get_children():
		child.queue_free()
	
	generate_path()
	fill_tokens()


func get_path_index(dir: Vector2):
	if int(dir.x) == -1:
		return 0
	if int(dir.y) == -1:
		return 1
	if int(dir.x) == 1:
		return 2
	if int(dir.y) == 1:
		return 3
	return -1

# 3: ╝ 2: ╚ 
# 0: ╗ 1: ╔ 
func get_corner_char(index: int):
	match index:
		0:
			return "╗"
		1:
			return "╔"
		2:
			return "╚"
		3:
			return "╝"

# 0: ║ 1: ═
func get_straight_char(index: int):
	match index:
		0:
			return "║"
		1:
			return "═"


func get_end_char(index: int):
	match index:
		0:
			return "╥"
		1:
			return "╞"
		2:
			return "╨"
		3:
			return "╡"

func generate_path():
	
	var corners = Paths.corners.size() / tile_types

	for i in range(4):
		availble_corners[i] = corners

	var straights = Paths.straights.size() / tile_types

	for i in range(2):
		availble_straights[i] = straights

	var pos = randi() % ((4 * (board_size - 1)) - 1)

	var start = Vector2(board_size - 2, board_size - 1)
	var dir = Vector2(-1, 0)

	while pos > 0:
		var new_start = start + dir
		if board_size > new_start.x and new_start.x >= 0 and \
			board_size > new_start.y and new_start.y >= 0:
			start = new_start
			pos -= 1
		else:
			dir = rotate_left(dir)

	var incoming_direction = rotate_left(dir)

	if pos % (board_size - 1) == 2 and bool(randi() % 2):
		incoming_direction = rotate_left(incoming_direction)



	choose_and_advance(start, incoming_direction)
#	choose_and_advance(Vector2(3, 2), Vector2(-1, -0))
	
#	print("----")
#	for i in range(board.size()):
#		var row = ""
#		for j in range(board.size()):
#			row += board[i][j]
#		print(row)


func rotate_left(vec):
	return Vector2(-vec.y, vec.x)

func rotate_right(vec: Vector2):
	return Vector2(vec.y, -vec.x)


# The unavailable slots are labeled as x
func choose_and_advance(start: Vector2, incoming_direction: Vector2):
#	print("...")
#	print(start, " ", incoming_direction)
	var forward = start + incoming_direction
	var left = start + rotate_left(incoming_direction)
	var right = start + rotate_right(incoming_direction)
	var neighbours = []
	var available_spaces = []
	
	
#	print("forward ", forward)
#	print("left ", left)
#	print("right ", right)
	
	if board_size > left.x and left.x >= 0 and \
			board_size > left.y and left.y >= 0 and \
			board[left.x][left.y] == "o":
			if availble_corners[get_path_index(incoming_direction)] > 0:
				neighbours.append(left)
			available_spaces.append(left)

	if board_size > right.x and right.x >= 0 and \
			board_size > right.y and right.y >= 0 and \
			board[right.x][right.y] == "o":
			if availble_corners[(get_path_index(incoming_direction) + 1) % 4] > 0:
				neighbours.append(right)
			available_spaces.append(right)
	
	if board_size > forward.x and forward.x >= 0 and \
			board_size > forward.y and forward.y >= 0 and \
			board[forward.x][forward.y] == "o":
			if availble_straights[get_path_index(incoming_direction) % 2] > 0:
				neighbours.append(forward)
			available_spaces.append(forward)
		
#	print("neighbours ", neighbours)

	# End
	if neighbours.size() == 0:
		var end_index = get_path_index(incoming_direction)
#		board[start.x][start.y] = get_end_char(end_index)
		board[start.x][start.y] = "e" + str(end_index)
#		spawn_end(start, end_index)
		return
	
	var chosen = neighbours[randi() % neighbours.size()]
	
	available_spaces.erase(chosen)
	
#	print("chosen ", chosen)

	# Make other neighbours unavailable
	for available_space in available_spaces:
		board[available_space.x][available_space.y] = "x"
		
	

	match chosen:
		left:
			var corner_index = get_path_index(incoming_direction)
#			board[start.x][start.y] = get_corner_char(corner_index)
			board[start.x][start.y] = "c" + str(corner_index)
			availble_corners[corner_index] -= 1
#			spawn_corner(start, corner_index)
		right:
			var corner_index = (get_path_index(incoming_direction) + 1) % 4
#			board[start.x][start.y] = get_corner_char(corner_index)
			board[start.x][start.y] = "c" + str(corner_index)
			availble_corners[corner_index] -= 1
#			spawn_corner(start, corner_index)
		forward:
			var straight_index = get_path_index(incoming_direction) % 2
#			board[start.x][start.y] = get_straight_char(straight_index)
			board[start.x][start.y] = "s" + str(straight_index)
			availble_straights[straight_index] -= 1
#			spawn_straight(start, straight_index)
	
#	print("----")
#	for i in range(board.size()):
#		var row = ""
#		for j in range(board.size()):
#			row += board[i][j]
#		print(row)
	
	
	choose_and_advance(chosen, chosen - start)

func spawn_corner(coords, type):
	var acts = available_corner_tokens[type]
	var chosen = acts[randi() % acts.size()]
	available_corner_tokens[type].erase(chosen)
	var corner: Spatial = Paths.corners[chosen + tile_type * Paths.corners.size() / tile_types].instance()
#	Tokens.add_child(corner)
	corner.transform.origin = \
		Vector3(coords.y - (board_size - 1) / 2.0, 0.0, coords.x - (board_size - 1) / 2.0)
	corner.rotation_degrees.y = 90 * type
	var tween = Tween.new()
	tween.name = "Tween"
	corner.add_child(tween)
	return corner

func spawn_straight(coords, type):
	var asts = available_straight_tokens[type]
	var chosen = asts[randi() % asts.size()]
	available_straight_tokens[type].erase(chosen)
	var straight: Spatial = Paths.straights[chosen + tile_type * Paths.straights.size() / tile_types].instance()
#	Tokens.add_child(straight)
	straight.transform.origin = \
		Vector3(coords.y - (board_size - 1) / 2.0, 0.0, coords.x - (board_size - 1) / 2.0)
	straight.rotation_degrees.y = 90 * type
	var tween = Tween.new()
	tween.name = "Tween"
	straight.add_child(tween)
	return straight

func spawn_end(coords, type):
	var chosen = randi() % 2
	var end: Spatial = Paths.ends[chosen + tile_type * Paths.ends.size() / tile_types].instance()
#	Tokens.add_child(end)
	end.transform.origin = \
		Vector3(coords.y - (board_size - 1) / 2.0, 0.0, coords.x - (board_size - 1) / 2.0)
	end.rotation_degrees.y = 90 * type
	var tween = Tween.new()
	tween.name = "Tween"
	end.add_child(tween)
	return end

func get_tile_or_tower():
	var chosen_index = randi() % (available_tower_tokens.size() + available_tile_tokens.size())
	
	var tween = Tween.new()
	tween.name = "Tween"
	
	if chosen_index < available_tower_tokens.size():
		var chosen = available_tower_tokens[chosen_index]
		available_tower_tokens.remove(chosen_index)
		var base = Tiles[0 + tile_type * Tiles.size() / tile_types].instance()
		var tower = Towers[chosen].instance()
		base.add_child(tower)
		tower.transform.origin.y = 0.2
		base.add_child(tween)
		return base
	else:
		chosen_index -= available_tower_tokens.size()
		var chosen = available_tile_tokens[chosen_index]
		available_tile_tokens.remove(chosen_index)
		var tile_or_tower = Tiles[chosen + tile_type * Tiles.size() / tile_types].instance()
		tile_or_tower.add_child(tween)
		return tile_or_tower

func get_tile():
	var chosen_index = randi() % available_tile_tokens.size()
	
	var chosen = available_tile_tokens[chosen_index]
	available_tile_tokens.remove(chosen_index)
	var tile = Tiles[chosen + tile_type * Tiles.size() / tile_types].instance()
	var tween = Tween.new()
	tween.name = "Tween"
	tile.add_child(tween)
	return tile
	

func get_tower():
	var chosen_index = randi() % available_tower_tokens.size()
	
	var chosen = available_tower_tokens[chosen_index]
	available_tower_tokens.remove(chosen_index)
	var base = Tiles[0 + tile_type * Tiles.size() / tile_types].instance()
	var tower = Towers[chosen].instance()
	base.add_child(tower)
	tower.transform.origin.y = 0.2
	var tween = Tween.new()
	tween.name = "Tween"
	base.add_child(tween)
	return base

func fill_tokens():
	for i in range(board.size()):
		var row = Spatial.new()
		Tokens.add_child(row)
		for j in range(board.size()):
			if board[i][j].begins_with("c"):
				var corner = spawn_corner(Vector2(i, j), int(board[i][j].right(1)))
				row.add_child(corner)
			if board[i][j].begins_with("s"):
				var corner = spawn_straight(Vector2(i, j), int(board[i][j].right(1)))
				row.add_child(corner)
			if board[i][j].begins_with("e"):
				var corner = spawn_end(Vector2(i, j), int(board[i][j].right(1)))
				row.add_child(corner)
			if board[i][j] == "o" or board[i][j] == "x":
				var tile: Spatial
				if i - 1 < 0 or j - 1 < 0:
					tile = get_tower()
				else:
					tile = get_tile()
				row.add_child(tile)
				tile.transform.origin = \
					Vector3(j - (board_size - 1) / 2.0, 0.0, i - (board_size - 1) / 2.0)
			if board[i][j] == "p":
				var cursor = Spatial.new()
				cursor.name = "Cursor"
				row.add_child(cursor)
				cursor.transform.origin = \
					Vector3(j - (board_size - 1) / 2.0, 0.0, i - (board_size - 1) / 2.0)


func init(player_index, master_tokens, shuffle_array):
	self.player_index = player_index
	var spi = str(player_index)
	move_left = "move_left_" + spi
	move_right = "move_right_" + spi
	move_up = "move_up_" + spi
	move_down = "move_down_" + spi
	action_a = "action_a_" + spi
	action_b = "action_b_" + spi
	
	for child in master_tokens.get_children():
		Tokens.add_child(child.duplicate())
	Dummy = Spatial.new()
	Dummy.name = "Dummy"
	Tokens.add_child(Dummy)
	
	board = []
	for i in range(board_size):
		var row = []
		for j in range(board_size):
			row.append(i * board_size + j)
		board.append(row)
	solution_board = board.duplicate(true)

	self.shuffle_array = shuffle_array
	
	shuffle_one()
	tween_timer = $Timer.wait_time
	$Timer.start()

func shuffle_one():
	var move = shuffle_array.pop_front()
	if move:
		move_cursor(move.x, move.y)
	else:
		$Timer.stop()
		tween_timer = 0.25
		is_shuffle_finished = true
		emit_signal("shuffle_finished")

func generate_shuffle_array():
	
	var shuffle_array = []
	var cursor = Vector2(board_size - 1, board_size - 1)
	
	var move_count = pow(board_size + 1, 2)
#	var move_count = 3
	var last_move = Vector2.ZERO
	
	while move_count > 0:
		var possible_moves = [
			Vector2(-1, 0),
			Vector2(0, -1),
			Vector2(1, 0),
			Vector2(0, 1)
		]
		var moves = []
		
		for move in possible_moves:
			var new_cursor = move + cursor
			if board_size > new_cursor.x and new_cursor.x >= 0 and \
				board_size > new_cursor.y and new_cursor.y >= 0 and \
				not(last_move.x == -move.x and last_move.y == -move.y):
					moves.append(move)
		var chosen = moves[randi() % moves.size()]
		last_move = chosen
		shuffle_array.append(chosen)
		cursor += chosen
		move_count -= 1
	
	return shuffle_array


func move_cursor(x, y):
	var cursor = Tokens.get_child(cursor_coords.x).get_child(cursor_coords.y)
	var cursor_position = Vector3(cursor_coords.y - (board_size - 1) / 2.0, 0, cursor_coords.x - (board_size - 1) / 2.0)
	var token = Tokens.get_child(cursor_coords.x + x).get_child(cursor_coords.y + y)
	var token_position = token.transform.origin
	
	Dummy.get_parent().remove_child(Dummy)
	cursor.get_parent().add_child_below_node(cursor, Dummy)
	
	cursor.get_parent().remove_child(cursor)
	token.get_parent().add_child_below_node(token, cursor)
	cursor.transform.origin = token_position
	
	token.get_parent().remove_child(token)
	Dummy.get_parent().add_child_below_node(Dummy, token)
	
	var tween: Tween = token.get_node("Tween")
	tween.stop_all()
#	token.global_transform.origin = cursor_position
	tween.interpolate_property(token, "transform:origin", token_position, cursor_position, tween_timer, Tween.TRANS_QUAD , Tween.EASE_OUT)
	tween.start()

	Dummy.get_parent().remove_child(Dummy)
	Tokens.add_child(Dummy)
	
	var new_cursor_coords = cursor_coords + Vector2(x, y)
	
	var cursor_token = board[cursor_coords.x][cursor_coords.y]
	board[cursor_coords.x][cursor_coords.y] = board[new_cursor_coords.x][new_cursor_coords.y]
	board[new_cursor_coords.x][new_cursor_coords.y] = cursor_token
	
#	for i in range(board_size):
#		print(board[i])
	
	cursor_coords = new_cursor_coords
	
	if is_shuffle_finished:
		check_board()

func check_board():
	for i in range(solution_board.size()):
		for j in range(solution_board.size()):
			if solution_board[i][j] != board[i][j]:
				return
	emit_signal("completed", player_index)


func _input(event):
	if is_shuffle_finished:
		var just_pressed = event.is_pressed() and not event.is_echo()
		if event.is_action_pressed(move_right):
			if cursor_coords.y > 0:
				move_cursor(0, -1)
		if event.is_action_pressed(move_left):
			if cursor_coords.y < board_size - 1:
				move_cursor(0, 1)
		if event.is_action_pressed(move_down):
			if cursor_coords.x > 0:
				move_cursor(-1, 0)
		if event.is_action_pressed(move_up):
			if cursor_coords.x < board_size - 1:
				move_cursor(1, 0)
