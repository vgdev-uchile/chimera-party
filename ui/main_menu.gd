extends Control

@onready var start_game: Button = %StartGame
@onready var options: Button = %Options
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit


func _ready() -> void:
	start_game.pressed.connect(_on_start_game_pressed)
	options.pressed.connect(_on_options_pressed)
	credits.pressed.connect(_on_credits_pressed)
	quit.pressed.connect(func (): get_tree().quit())


func _on_start_game_pressed():
	Game.load_scene("res://scenes/lobby.tscn")


func _on_options_pressed():
	pass


func _on_credits_pressed():
	pass
