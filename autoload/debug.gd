extends Node


@onready var canvas_layer  = CanvasLayer.new()
@onready var container = VBoxContainer.new()

func _ready() -> void:
	if !OS.is_debug_build() && !Engine.is_editor_hint():
		return
	add_child(canvas_layer)
	canvas_layer.layer = 1000
	canvas_layer.add_child(container)


func log(message: Variant, seconds: int = 2) -> void:
	if !OS.is_debug_build() && !Engine.is_editor_hint():
		return
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		print(message)
	else:
		print_rich("[b]%s:[/b] " % (("Server") if multiplayer.is_server() else "Client"), message)
	var label = Label.new()
	label.text = str(message)
	label.set("theme_override_constants/outline_size", 2)
	label.set("theme_override_colors/font_outline_color", Color.BLACK)
	container.add_child(label)
	container.move_child(label, 0)
	await get_tree().create_timer(seconds).timeout
	container.remove_child(label)
	label.queue_free()
