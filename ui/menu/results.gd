extends Control

@export var score_card_scene: PackedScene
var _done_count = 0
@onready var score_card_container: HBoxContainer = %ScoreCardContainer


func _ready() -> void:
	if not score_card_scene:
		return
	for player in Game.players:
		var score_card_inst = score_card_scene.instantiate()
		score_card_container.add_child(score_card_inst)
		score_card_inst.setup(player)
		score_card_inst.done.connect(_on_card_done)


func _on_card_done() -> void:
	_done_count += 1
	if _done_count == Game.players.size():
		if Game.is_last_level():
			Game.game_over()
		else:
			Game.load_random_game()
