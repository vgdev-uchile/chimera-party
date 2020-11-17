extends Node2D


# Declare member variables here. Examples:
export var move_speed = 5
export var repeat_distance = 600

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	self.position.y += move_speed*delta
	while self.position.y > repeat_distance:
		self.position.y -= repeat_distance
