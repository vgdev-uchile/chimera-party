extends Node
const random_pattern_factory = preload("res://games/scrap_road/scripts/RandomDebris.gd")
const big_random_pattern_factory = preload("res://games/scrap_road/scripts/RandomBigDebris.gd")
const bigger_random_pattern_factory = preload("res://games/scrap_road/scripts/RandomBiggerDebris.gd")
const biggest_random_pattern_factory = preload("res://games/scrap_road/scripts/RandomBiggestDebris.gd")
const wall_pattern_factory = preload("res://games/scrap_road/scripts/WallsDebris.gd")
const sine_pattern_factory = preload("res://games/scrap_road/scripts/SineDebris.gd")
const messy_road_pattern_factory = preload("res://games/scrap_road/scripts/MessyRoadDebris.gd")

export var start_spawn_area = 640
export var end_spawn_area = 1240
export var spawn_altitude = 50

var rng = RandomNumberGenerator.new()

var patterns = Array()
var current_pattern = null

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	var random_pattern_1 = random_pattern_factory.new()
	random_pattern_1.set_box_spawner(self)
	random_pattern_1.set_time_interval(0.15)
	random_pattern_1.set_time_to_stop(3)
	random_pattern_1.reset()
	
	var random_pattern_2 = random_pattern_factory.new()
	random_pattern_2.set_box_spawner(self)
	random_pattern_2.set_time_to_stop(3)
	random_pattern_2.reset()
	
	var random_pattern_3 = random_pattern_factory.new()
	random_pattern_3.set_box_spawner(self)
	random_pattern_3.set_time_interval(0.10)
	random_pattern_3.set_time_to_stop(2)
	random_pattern_3.reset()
	
	var wall_pattern = wall_pattern_factory.new()
	wall_pattern.set_box_spawner(self)
	wall_pattern.set_hole_size(200)
	wall_pattern.reset()
	
	var messy_road_pattern = messy_road_pattern_factory.new()
	messy_road_pattern.set_box_spawner(self)
	messy_road_pattern.set_box_spacing(200)
	messy_road_pattern.set_hole_size(200)
	messy_road_pattern.reset()
	
	var sine_pattern = sine_pattern_factory.new()
	sine_pattern.set_box_spawner(self)
	sine_pattern.reset()
	
	var big_random_pattern = big_random_pattern_factory.new()
	big_random_pattern.set_box_spawner(self)
	big_random_pattern.reset()
	
	var bigger_random_pattern = bigger_random_pattern_factory.new()
	bigger_random_pattern.set_box_spawner(self)
	bigger_random_pattern.reset()
	
	var biggest_random_pattern = biggest_random_pattern_factory.new()
	biggest_random_pattern.set_box_spawner(self)
	biggest_random_pattern.reset()
	
	patterns.append(random_pattern_1)
	patterns.append(random_pattern_2)
	patterns.append(random_pattern_3)
	patterns.append(wall_pattern)
	patterns.append(messy_road_pattern)
	patterns.append(sine_pattern)
	patterns.append(big_random_pattern)
	patterns.append(bigger_random_pattern)
	patterns.append(biggest_random_pattern)
	change_pattern()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.active:
		current_pattern.update(delta)
		
		despawn_offscreen_debris()
		if current_pattern.is_finished():
			change_pattern()

# add_debris: KinematicBody2D
# adds a debris object to the road
func add_debris(debris):
	$Debris.add_child(debris)

# despawn_offscreen_debris
# despawns the debris that exited the screen
func despawn_offscreen_debris():
	for child in $Debris.get_children():
		if child.position.y > (ProjectSettings.get_setting("display/window/size/height") + 400):
			child.queue_free()

# change_pattern
# changes the current pattern to a random pattern
func change_pattern():
	current_pattern = patterns[rng.randi_range(0, len(patterns) - 1)]
	current_pattern.reset()

# clear_debris
# clears the debris if the spawner
func clear_debris():
	for child in $Debris.get_children():
		child.queue_free()

# reset
# resets the spawner and the debris spawned
func reset():
	self.clear_debris()
	self.change_pattern()

# getters
func get_start_spawn_area():
	return start_spawn_area

func get_end_spawn_area():
	return end_spawn_area

func get_spawn_altitude():
	return spawn_altitude

# setter
func set_active(new_active):
	self.active = new_active
