extends Node2D

var fire_index = 0
var started = false

func _on_tick_timer_timeout():
	if !(started && fire_index == 0):
		if started:
			fire_index -= 1
			get_node("fire_" + str(fire_index)).visible = false
			$fire_out.play()
		else:
			get_node("fire_" + str(fire_index)).visible = true
			fire_index += 1
			$fire_in.play()
			if fire_index == 12:
				started = true
				$tick_timer.set_wait_time(7.5)
				for i in range(12):
					var j = i
					get_node("fire_" + str(i)).modulate = Color("#0200ff")
		$tick_timer.start()

