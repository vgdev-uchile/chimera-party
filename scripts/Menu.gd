extends CanvasLayer


func _ready():
	$Panel/VBoxContainer/NewGame.connect("pressed", self, "on_new_game")
	$Panel/VBoxContainer/NewGame.grab_focus()


func on_new_game():
	Party._next()
