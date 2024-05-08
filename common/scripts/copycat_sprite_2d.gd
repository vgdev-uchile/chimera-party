@tool
class_name CopycatSprite2D
extends Sprite2D

@export var source: Sprite2D


func _ready() -> void:
	if source:
		source.draw.connect(_on_draw)


func _on_draw():
	if source:
		if hframes != source.hframes:
			hframes = source.hframes
		if vframes != source.vframes:
			vframes = source.vframes
		if frame_coords != source.frame_coords:
			frame_coords = source.frame_coords
