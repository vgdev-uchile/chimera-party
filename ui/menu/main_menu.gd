extends Control

@onready var start_game: ClipboardButton = %StartGame
@onready var options: ClipboardButton = %Options
@onready var credits: ClipboardButton = %Credits
@onready var quit: ClipboardButton = %Quit


func _ready() -> void:
	start_game.pressed.connect(_on_start_game_pressed)
	options.pressed.connect(_on_options_pressed)
	credits.pressed.connect(_on_credits_pressed)
	quit.pressed.connect(func (): get_tree().quit())
	
	start_game.grab_focus()


func _on_start_game_pressed():
	Game.load_scene("res://scenes/lobby.tscn")


func _on_options_pressed():
	pass


func _on_credits_pressed():
	pass

