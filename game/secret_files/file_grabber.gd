class_name FileGrabber
extends Area2D

signal files_taken


var has_files: bool = false:
	set(value):
		has_files = value
		if sprite_2d:
			sprite_2d.visible = has_files
		if has_files:
			files_taken.emit()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	


func take_files() -> bool:
	if not timer.is_stopped() or not has_files:
		return false
	has_files = false
	return true


func disable(value: bool) -> void:
	collision_shape_2d.set_deferred("disabled", value)


func _on_body_entered(body: Node2D):
	if has_files or body == get_parent():
		return
	var player = body as Chimerin
	if player:
		var file_grabber = get_file_grabber(player)
		has_files = file_grabber.take_files()
		if has_files:
			timer.start()


static func get_file_grabber(player: Chimerin) -> FileGrabber:
	for child in player.get_children():
		if child is FileGrabber:
			return child
	return null
