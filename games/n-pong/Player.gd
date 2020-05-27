extends KinematicBody2D

export var ROT_SPEED: float = 1.4
var rot_speed = 0
var initial_rotation_degrees: float
var scene
var field
var seq_number
var lives = 3

var player_index
var player_color

# Inputs
var move_left = ""
var move_right = ""
var move_up = ""
var move_down = ""
var action_a = ""
var action_b = ""


func lose_life():
	lives -= 1
	return lives == 0
		
		
func color():
	return Party.available_colors[player_color]


func init(player_index, player_color):
	self.player_index = player_index
	self.player_color = player_color
	$Sprite.modulate = Party.available_colors[player_color]
	var spi = str(player_index)
	move_left = "move_left_" + spi
	move_right = "move_right_" + spi
	move_up = "move_up_" + spi
	move_down = "move_down_" + spi
	action_a = "action_a_" + spi
	action_b = "action_b_" + spi


func zoom():
	return 3.0 / field.num_players()


func start():
	scale = Vector2(zoom(), zoom())
	
	var center = get_viewport_rect().size / 2
	var radius = scene.radius

	position = center
	$Sprite.position.x = radius / zoom()
	$CollisionShape2D.position.x = radius / zoom()
	rotation = TAU / scene.player_num * seq_number
	initial_rotation_degrees = rotation_degrees


func max_abs(a, b):
	if abs(a) > abs(b):
		return a
	else:
		return b


func strength(action, invert):
	if invert:
		return -Input.get_action_strength(action) 
	else:
		return Input.get_action_strength(action)


func _physics_process(delta):
	var invert_x = initial_rotation_degrees >= 180
	var invert_y = abs(initial_rotation_degrees) >= 90
	
	var inc_strength = max_abs(strength(move_left, invert_x),
							   strength(move_down, invert_y))
	var dec_strength = max_abs(strength(move_right, invert_x),
							   strength(move_up, invert_y))
	var target_rot_speed = (inc_strength - dec_strength) * ROT_SPEED * zoom()

	
	var old_transform = transform
	rotate(target_rot_speed * delta)
	var new_transform = transform
	transform = old_transform
	
	var would_collide = test_move(new_transform, Vector2.ZERO)
	if not would_collide:
		transform = new_transform
