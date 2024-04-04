extends PanelContainer

signal done

@onready var body: TextureRect = %Body
@onready var score: Label = %Score
@onready var local_score: Label = %LocalScore
@onready var wins: Label = %Wins


func _ready() -> void:
	local_score.hide()
	wins.hide()


func setup(data: PlayerData) -> void:
	_set_color(data.primary_color)
	score.text = str(data.score)
	#await get_tree().create_timer(1).timeout
	local_score.text = "+" + str(data.local_score)
	local_score.show()
	await get_tree().create_timer(2).timeout
	local_score.hide()
	data.score += data.local_score
	data.local_score = 0
	score.text = str(data.score)
	await get_tree().create_timer(3).timeout
	if Game.is_last_level():
		if Game.is_winner(data):
			wins.show()
		await get_tree().create_timer(3).timeout
	done.emit()


func _set_color(color: Color) -> void:
	self_modulate = color
	body.self_modulate = color
