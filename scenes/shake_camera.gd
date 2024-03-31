extends Camera2D


func shake(strenght: float = 100, duration: float = 0.2, times: int = 10) -> void:
	var delta = duration / times
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	for i in times:
		tween.tween_property(self, "offset", _get_random_vector() * strenght, delta)
	tween.tween_property(self, "offset", Vector2.ZERO, delta)


func _get_random_vector() -> Vector2:
	return Vector2(randf() * 2 - 1, randf() * 2 - 1)
