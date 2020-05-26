extends RigidBody2D


export var value = 1

func _ready():
	self.z_index = 10

func get_value():
	return value
