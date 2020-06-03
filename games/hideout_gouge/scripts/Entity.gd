extends KinematicBody2D

class_name Entity

# Entity variables
var SPEED
var health = 1
var state = "moving"
var type
var hitstun = 10
var knock_dir = Vector2(0,0)
var damage = 0

func state_moving():
	pass

func state_death():
	pass

func play_death():
	pass

func take_damage(entity):
	pass
	
