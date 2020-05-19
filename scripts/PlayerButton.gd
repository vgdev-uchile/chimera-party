tool

extends Control

class_name PlayerButton

signal pressed
signal selected

export var text: String setget set_text, get_text

export var previous: NodePath
onready var _previous = get_node(previous)
export var next: NodePath
onready var _next = get_node(next)

export var _is_select: bool = false setget set_select, is_select
export var _is_toggle: bool = false setget set_toggle, is_toggle

var navigation = true
export var enabled: bool = true

export(Array, String) var options = []
var current_option = -1 setget set_current_option

var _was_pressed = false

func set_current_option(new_option):
	current_option = new_option
	if _is_select:
		emit_signal("selected", current_option)
	set_text(options[current_option])


func set_text(new_text):
	text = new_text
	$Label.text = text

func get_text():
	return text

func set_select(new_value):
	_is_select = new_value
	$SelectLeft.visible = _is_select
	$SelectRight.visible = _is_select
	if _is_select and options.size() > 0:
		set_current_option(0)

func is_select():
	return _is_select

func set_toggle(new_value):
	_is_toggle = new_value
	if _is_toggle and options.size() > 0:
		set_text(options[0])

func is_toggle():
	return _is_toggle
	
func toggle():
	if _is_toggle and options.size() > 0:
		set_current_option((current_option + 1) % options.size())
	
func _ready():
	if (_is_select or _is_toggle) and options.size() > 0:
		set_current_option(0)

func press():
	_was_pressed = true
	if not _is_select and enabled:
		$AnimationPlayer.play("press")

func release():
	if not _is_select and _was_pressed and enabled:
		$AnimationPlayer.play("release")
		emit_signal("pressed")
	_was_pressed = false
	

func focus(value: bool):
	if value:
		$NinePatchRect.self_modulate = Color("5c84bd")
	else:
		$NinePatchRect.self_modulate = Color.white

func go_previous():
	if _previous and navigation:
		focus(false)
		_previous.focus(true)
		return _previous
	return self

func go_next():
	if _next and navigation:
		focus(false)
		_next.focus(true)
		return _next
	return self

func choose_next():
	if _is_select and options.size() > 0:
		set_current_option((options.size() + current_option + 1) % options.size())

func choose_previous():
	if _is_select and options.size() > 0:
		set_current_option((options.size() +  current_option - 1) % options.size())
