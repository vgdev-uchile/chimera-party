@tool
extends Area2D

@export_range(0, 1) var alpha: float:
	set(value):
		alpha = value
		if sprite_2d:
			sprite_2d.modulate.a = alpha

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if sprite_2d:
			sprite_2d.modulate = color
			sprite_2d.modulate.a = alpha
			

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	self.color = color


func _on_body_entered(body: Node2D):
	var player = body as Chimerin
	if player:
		player.change_color(color)
