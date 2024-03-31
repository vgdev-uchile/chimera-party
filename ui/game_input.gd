extends HBoxContainer

@onready var input_texture: InputTexture = $InputTexture
@onready var label: Label = %Label

# Call after add_child
func setup(game_input: GameInput) -> void:
	label.text = game_input.description
	input_texture.inputs = game_input.inputs
	
