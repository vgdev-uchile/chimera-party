extends Node2D

var trembling = false
var current_time = 0
export var tremble_amplitude = 20
export var tremble_speed = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	self.current_time += delta
	if self.trembling:
		self.position.x = sin(self.current_time*tremble_speed)*tremble_amplitude

# stop_trembling
# stops the message tremble animation
func stop_trembling():
	self.position.x = 0
	self.trembling = false

# tremble
# starts the message tremble animation
func tremble():
	self.trembling = true
	$TrembleTimer.start()

# _on_TrembleTimer_timeout
# stops trembling
func _on_TrembleTimer_timeout():
	self.stop_trembling()
