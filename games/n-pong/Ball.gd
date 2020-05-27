extends KinematicBody2D

var slow_speed = 200
var medium_speed = 400 
var fast_speed = 700
var speed_increment = 25

var speed = 0

onready var radius = $CollisionShape2D.shape.radius
var direction = Vector2.ZERO


func _ready():
	reset()
	
	
func _physics_process(delta):
	var velocity = direction * speed
	move_and_slide(velocity)
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if collision != null:
			direction = direction.bounce(collision.normal)
			on_bounce()


func on_bounce():
	speed += speed_increment


func reset():
	var center = get_viewport_rect().size / 2
	position = center
	direction = random_unit_vector()
	speed = 0
	

func start_moving():
	direction = random_unit_vector()
	speed = slow_speed


func random_unit_vector():
	var theta = rand_range(0, TAU)
	return Vector2(cos(theta), sin(theta))
	

func angle():
	var center = get_viewport_rect().size / 2
	return (position - center).angle()
