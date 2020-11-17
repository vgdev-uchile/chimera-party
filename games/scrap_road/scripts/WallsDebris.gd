extends "res://games/scrap_road/scripts/SpawnPattern.gd"
const pre_box_factory = preload("res://games/scrap_road/scenes/Box.tscn")


# Declare member variables here. Examples:
var time_to_stop = 6
var time_interval = 1

var box_spacing = 16
var hole_bigness = 100

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	self.reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# reset
# resets the pattern to a new random wall parttern
func reset():
	.reset()
	spawns = Array()
	
	var start_pos = self.box_spawner.get_start_spawn_area()
	var end_pos = self.box_spawner.get_end_spawn_area()
	
	var hole_pos = rand_range(start_pos, end_pos)
	
	var accumulated_interval = 0
	while accumulated_interval < time_to_stop:		
		for x_pos in range(start_pos, end_pos, box_spacing):
			if abs(hole_pos - x_pos) > hole_bigness:
				var position = Vector2(x_pos, -self.box_spawner.get_spawn_altitude())
				spawns.append([pre_box_factory, accumulated_interval, position])
		
		hole_pos = rand_range(start_pos, end_pos)
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

func set_box_spacing(new_box_specing):
	box_spacing = new_box_specing

func set_hole_size(new_size):
	hole_bigness = new_size
