extends Control

@onready var image: TextureRect = %Image
@onready var title: Label = %Title
@onready var description: RichTextLabel = %Description


func _ready() -> void:
	var info = Game.get_current_game_info()
	if not info:
		Debug.log("Game %s has no info" % Game.current_game)
		return
	image.texture = info.image
	title.text = info.name
	description.text = info.description

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Game.load_current_game()
