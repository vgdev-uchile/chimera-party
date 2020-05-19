extends RigidBody2D


export var SPEED: float = 8000

var facing_right = true

onready var playback = $AnimationTree.get("parameters/playback")

onready var green = preload("res://games/extinguish/sprites/dinoCharactersVersion1.1/sheets/DinoSprites - vita.png")
onready var red = preload("res://games/extinguish/sprites/dinoCharactersVersion1.1/sheets/DinoSprites - mort.png")
onready var yellow = preload("res://games/extinguish/sprites/dinoCharactersVersion1.1/sheets/DinoSprites - tard.png")
onready var blue = preload("res://games/extinguish/sprites/dinoCharactersVersion1.1/sheets/DinoSprites - doux.png")

var dead = false
var disabled = false
signal player_died
var player_index
var player_color

# Inputs

var move_left = "move_left"
var move_right = "move_right"
var move_up = "move_up"
var move_down = "move_down"
var action_a = "action_a"
var action_b = "action_b"

func _ready():
	mode = RigidBody2D.MODE_CHARACTER

func init(player_index, player_color):
	self.player_index = player_index
	self.player_color = player_color
	match player_color:
		0:
			$shadow_2/Sprite.texture = green
		1:
			$shadow_2/Sprite.texture = red
		2:
			$shadow_2/Sprite.texture = yellow
		3:
			$shadow_2/Sprite.texture = blue
	var spi = str(player_index)
	move_left = "move_left_" + spi
	move_right = "move_right_" + spi
	move_up = "move_up_" + spi
	move_down = "move_down_" + spi
	action_a = "action_a_" + spi
	action_b = "action_b_" + spi


func death():
	playback.travel("hurt")
	dead = true
	linear_damp *= 5
	emit_signal("player_died", self)

func _physics_process(delta):
	var target_vel = Vector2(Input.get_action_strength(move_right) - Input.get_action_strength(move_left),
	Input.get_action_strength(move_down) - Input.get_action_strength(move_up))
	
	if dead or disabled:
		target_vel = Vector2.ZERO
	
	apply_central_impulse(target_vel * SPEED * delta)
	
	if not dead and not disabled:
		if linear_velocity.length_squared() > 10 :
			playback.travel("run")
		else:
			playback.travel("idle")
		
		if Input.is_action_just_pressed(action_a):
			playback.travel("kick")
			if target_vel != Vector2.ZERO:
				apply_central_impulse(target_vel * 20 * SPEED * delta)
		
		if Input.is_action_pressed(move_left) and not Input.is_action_pressed(move_right):
			$shadow_2/Sprite.flip_h = true
		if Input.is_action_pressed(move_right) and not Input.is_action_pressed(move_left):
			$shadow_2/Sprite.flip_h = false
		
