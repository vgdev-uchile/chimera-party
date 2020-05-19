extends ColorRect

signal finished_fading

export var is_faded = true setget set_is_faded, get_is_faded
export var duration = 1.0
var alpha = 1.0

func set_is_faded(new_value: bool):
	is_faded = new_value
	set_process(true)

func get_is_faded():
	return is_faded

func _process(delta):
	if is_faded:
		if alpha < 1.0:
			alpha = clamp(alpha + (delta / duration), 0.0, 1.0)
		else:
			set_process(false)
			emit_signal("finished_fading")
	else:
		if alpha > 0.0:
			alpha = clamp(alpha - (delta / duration), 0.0, 1.0)
		else:
			set_process(false)
			emit_signal("finished_fading")
	color.a = alpha
	
	visible = alpha > 0
