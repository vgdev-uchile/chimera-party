extends ColorRect

signal finished_fading

export var duration = 1.0

func _ready():
	$Tween.connect("tween_all_completed", self, "on_tween_completed")

# Show screen
func fade_in():
	$Tween.interpolate_property(self, "color:a", 1.0, 0.0, duration, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()

# Hide screen
func fade_out():
	$Tween.interpolate_property(self, "color:a", 0.0, 1.0, duration, Tween.TRANS_QUART, Tween.EASE_IN)
	$Tween.start()

func on_tween_completed():
	emit_signal("finished_fading")

	

