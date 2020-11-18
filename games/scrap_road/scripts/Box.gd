extends KinematicBody2D


# box's speed
export var speed = 2

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_collide(Vector2.DOWN*speed)

