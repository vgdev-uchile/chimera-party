class_name PlayerController
extends Node
## Base component for a controllable node.
##
## Simplifies interaction with Chimera Party's input system.
## It allows you to get the correct input actions for a given [PlayerData].
## Every controllable node must have its player's color (be a character, a button, etc),
## and this node provides an easy way to set it up.[br]
## In the parent node you must connect [signal color_change] and forward [method setup]:
## [codeblock]
## # my_player.gd
## @onready var pc: PlayerController = PlayerController
##
## func _ready() -> void:
##     pc.color_changed.connect(_on_color_changed)
##
## func setup(player_data: PlayerData) -> void:
##     pc.setup(player_data)
##
## func _on_color_changed(color: Color) -> void:
##     visual_element.color = color
## [/codeblock]
##
## You also must call [method setup] [b]after[/b] adding your controllable node to the game. For example if you want to add players to the main scene:
## [codeblock]
## # main.gd
## @export var my_player_scene: PackedScene
## 
## func _ready() -> void:
##     if not my_player_scene:
##         return
##     for player_data in Game.players:
##         var my_player_inst = my_player_scene.instantiate()
##         add_child(my_player_inst)          # fist call add_child
##         my_player_inst.setup(player_data)  # then call setup
## [/codeblock]
##
## For accessing the inputs you may do something like this:
## [codeblock]
## # my_player.gd
## @onready var pc: PlayerController = $PlayerController
##
## func _physics_process(delta: float) -> void:
##     var move_input = Input.get_vector(
##         pc.move_left,
##         pc.move_right,
##         pc.move_up,
##         pc.move_down
##     )
##     # do something with move_input
##
## func _input(event: InputEvent) -> void:
##     if event.is_action_pressed(pc.action_a):
##         # action_a was pressed, do something
## [/codeblock]


## Emitted when the current controllable node must change color.
signal color_changed(color)


## Player data.
var data: PlayerData:
	set(value):
		var last_data = data
		data = value
		move_left = "move_left_%d" % data.input
		move_right = "move_right_%d" % data.input
		move_up = "move_up_%d" % data.input
		move_down = "move_down_%d" % data.input
		action_a = "action_a_%d" % data.input
		action_b = "action_b_%d" % data.input
		if not last_data or last_data.color != data.color:
			color_changed.emit(data.color)


## Move left action name.
var move_left: StringName = "move_left"
## Move right action name.
var move_right: StringName = "move_right"
## Move up action name.
var move_up: StringName = "move_up"
## Move down action name.
var move_down: StringName = "move_down"
## Action A action name.
var action_a: StringName  = "action_a"
## Action B action name.
var action_b: StringName  = "action_b"


## Setup player data.[br]
## Must be called [b]after[/b] adding its parent to the game.
func setup(player_data: PlayerData) -> void:
	data = player_data
