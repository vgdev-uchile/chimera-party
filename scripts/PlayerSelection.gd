extends Node2D

signal leave
signal player_ready

var _player_index = -1
var focused = null
var _keyset_index = -1 setget , get_keyset_index
var _player_color = -1

var _player_ready = false

func get_keyset_index():
	return _keyset_index

func init(keyset_index: int, player_index: int):
	
	
	 
	if focused:
		focused.focus(false)
	_player_index = player_index
	_keyset_index = keyset_index
	_player_color = $ColorSelect.options.size() - 1
	Party._players[_player_index].color = _player_color	
	$Panel/Keyset.set_keyset(str(keyset_index))
	$Color.focus(true)
	focused = $Color


func set_available_keyset(value, index):
	$Panel/Keyset.set_available(value, index)

func reset():
	Party._clear_player(_player_index)
	$Panel/Keyset.clear_ketset()
	if focused:
		focused.focus(false)
	focused = null
	_keyset_index = -1
	_player_index = -1
	on_ColorSelect_selected($ColorSelect.options.size() - 1)
	_player_color = -1
	


func _ready():
	$Leave.connect("pressed", self, "on_Leave_pressed")
	$Color.connect("pressed", self, "on_Color_pressed")
	$Ok.connect("pressed", self, "on_Ok_pressed")
	$Ready.connect("pressed", self, "on_Ready_pressed")
	$ColorSelect.connect("selected", self, "on_ColorSelect_selected")
	$ColorSelect.current_option = $ColorSelect.options.size() - 1
	_player_color = -1
	
func on_Leave_pressed():
	if _player_ready:
		emit_signal("player_ready", _player_index, false)
		$Leave.toggle()
		$Leave.navigation = true
		_player_ready = false
	else:
		emit_signal("leave", _player_index)
		reset()

func on_Color_pressed():
	$Ready.visible = false
	$Leave.visible = false
	$ColorSelect.visible = true
	$Ok.visible = true
	$ColorSelect.focus(true)
	$Ok.focus(false)
	focused = $ColorSelect

func on_Ok_pressed():
	if Party._players[_player_index].color == _player_color or \
	Party._available_color(_player_color):
		Party._players[_player_index].color = _player_color
		$Ready.visible = true
		$Leave.visible = true
		$ColorSelect.visible = false
		$Ok.visible = false
		focused = $Color

func on_Ready_pressed():
	if _player_color >= 0:
		emit_signal("player_ready", _player_index, true)
		_player_ready = true
		$Leave.toggle()
		$Leave.navigation = false
		focused = focused.go_next()

func on_ColorSelect_selected(option):
	_player_color = option
	for i in range($ColorSelect.options.size()):
		$Panel/Avatars.get_child(i).visible = i == _player_color

func go():
	randomize()
	if _player_color == $ColorSelect.options.size() - 1:
		var colors = Party._get_available_colors()
		Party._players[_player_index].color = colors[randi() % colors.size()]
	set_process_input(false)
	


func _input(event):
	var spi = str(_player_index)
	if focused:
		var just_pressed = event.is_pressed() and not event.is_echo()
		if event.is_action_pressed("move_down_"+ spi) and just_pressed:
			focused = focused.go_next()
		if event.is_action_pressed("move_up_"+ spi) and just_pressed:
			focused = focused.go_previous()
		if event.is_action_pressed("move_right_"+ spi) and just_pressed:
			focused.choose_next()
		if event.is_action_pressed("move_left_"+ spi) and just_pressed:
			focused.choose_previous()
		if event.is_action_pressed("action_a_"+ spi):
			focused.press()
		if event.is_action_released("action_a_"+ spi):
			focused.release()
