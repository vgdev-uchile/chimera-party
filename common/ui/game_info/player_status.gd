extends HBoxContainer


signal status_changed()

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var pc: PlayerController = $PlayerController


var is_ready: bool = false:
	set(value):
		is_ready = value
		if is_ready:
			label.text = "Ready"
		else:
			label.text = "Waiting"
		status_changed.emit()


func _ready() -> void:
	pc.color_changed.connect(_on_color_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(pc.action_a):
		is_ready = true
	if event.is_action_pressed(pc.action_b):
		is_ready = false


func setup(player_data: PlayerData) -> void:
	pc.setup(player_data)


func _on_color_changed(color: Color) -> void:
	color_rect.color = color
