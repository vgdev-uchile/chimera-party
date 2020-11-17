extends Node

var current_time = 0
var spawns = Array()
var debris_to_spawn = Array()
var box_spawner = null

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

# update: num
# updates the current time, spawns the pending debris and updates the pending
# debris list
func update(delta):
	current_time += delta
	spawn_debris()
	remove_spawned_debris_from_list()

# reset
# resets spawn pattern
func reset():
	current_time = 0
	for debris_tuple in spawns:
		debris_to_spawn.append(debris_tuple)

# spawn_debris
# Spawns the debris in the list
func spawn_debris():
	for debris_tuple in debris_to_spawn:
		var debris_factory = debris_tuple[0]
		var debris_time = debris_tuple[1]
		var debris_position = debris_tuple[2]
		
		if debris_time < self.current_time:
			var debris_to_add = debris_factory.instance()
			debris_to_add.position = debris_position
			
			self.box_spawner.add_debris(debris_to_add)

# remove_spawned_debris_from_list
# Removes the already spawned debris from the list of debris to spawn
func remove_spawned_debris_from_list():
	var debris_to_remove = Array()
	for i in range(len(debris_to_spawn)):
		var debris_tuple = debris_to_spawn[i]
		var debris_factory = debris_tuple[0]
		var debris_time = debris_tuple[1]
		var debris_position = debris_tuple[2]
		
		if debris_time < self.current_time:
			debris_to_remove.append(i)
	
	for debris_tuple_index in debris_to_remove:
		debris_to_spawn.remove(debris_tuple_index)

# is_finished
# Checks if the pattern is finished
func is_finished():
	return debris_to_spawn.empty()

# setters
func set_box_spawner(new_box_spawner):
	self.box_spawner = new_box_spawner
