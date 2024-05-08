extends HBoxContainer

@onready var input_texture: InputTexture = $InputTexture
@onready var label: Label = %Label

var _game_input: GameInput


func _ready() -> void:
	if _game_input:
		_update()

func setup(game_input: GameInput) -> void:
	_game_input = game_input
	if is_inside_tree():
		_update()

func _update() -> void:
	label.text = _game_input.description
	input_texture.inputs = _game_input.inputs
