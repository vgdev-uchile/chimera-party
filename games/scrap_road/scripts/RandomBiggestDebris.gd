extends "res://games/scrap_road/scripts/SpawnPattern.gd"
const pre_box_factory = preload("res://games/scrap_road/scenes/BiggestBox.tscn")

var time_to_stop = 3
var time_interval = 1.5

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	self.reset()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# reset
# resets the pattern to a new random parttern
func reset():
	.reset()
	spawns = Array()
	
	var accumulated_interval = 0
	while accumulated_interval < time_to_stop:
		var x_position = rng.randf_range(self.box_spawner.get_start_spawn_area(), self.box_spawner.get_end_spawn_area())
		var position = Vector2(x_position, -self.box_spawner.get_spawn_altitude() - 400)
		
		spawns.append([pre_box_factory, accumulated_interval, position])
		accumulated_interval += time_interval

# is_finished
# Checks if the pattern is finished
func is_finished():
	return current_time > time_to_stop

# setters
func set_time_to_stop(new_time_to_stop):
	time_to_stop = new_time_to_stop

func set_time_interval(new_time_interval):
	time_interval = new_time_interval
