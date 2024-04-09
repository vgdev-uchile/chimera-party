@tool
class_name ClipboardButton
extends HBoxContainer


signal pressed

@export_multiline var text: String:
	set(value):
		text = value
		if is_inside_tree():
			_update_label()
@export var disabled: bool = false
@export var disable_self_on_press = true
@export var disable_siblings_on_press = true

@onready var label: Label = %Label
@onready var focus_animation_player: AnimationPlayer = %FocusAnimationPlayer
@onready var check_animation_player: AnimationPlayer = %CheckAnimationPlayer


func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(func(): grab_focus())
	_update_label()


func _gui_input(event: InputEvent) -> void:
	if disabled or Game.loading:
		return
	
	if event.is_action_pressed("ui_accept"):
		_press()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_press()


func _on_focus_entered() -> void:
	if disabled or Game.loading:
		return
	focus_animation_player.play("focus")


func _on_focus_exited() -> void:
	if disabled or Game.loading:
		return
	focus_animation_player.play("RESET")


func _update_label() -> void:
	label.text = text


func _press() -> void:
	_disable_siblings(true)
	check_animation_player.play("check")
	await check_animation_player.animation_finished
	pressed.emit()
	accept_event()
	_disable_siblings(false)


func _disable_siblings(disable: bool) -> void:
	if not get_parent():
		return
	for sibling in get_parent().get_children():
		var clipboard_button = sibling as ClipboardButton
		if not clipboard_button:
			continue
		if clipboard_button == self and disable_self_on_press:
			disabled = disable
		elif disable_siblings_on_press:
			clipboard_button.disabled = disable
