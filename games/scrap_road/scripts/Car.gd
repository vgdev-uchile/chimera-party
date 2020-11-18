extends KinematicBody2D
const dust_particle_effect = preload("res://games/scrap_road/scenes/DustParticle.tscn")

var player_index
var player_color

# Inputs
var move_left = ""
var move_right = ""
var move_up = ""
var move_down = ""
var action_a = ""
var action_b = ""

var active = false

export var h_speed = 5
export var up_speed = 0.05
export var break_speed = 5
export var rotation_speed = 10

export var player_name = "player1"

export var crash_speed = 3
var crash_mode = false
export var crash_mode_cooldown = 1.0
var current_crash_mode_cooldown = 1

var current_time = 0
var dust_partice_interval = 0.08

# Called when the node enters the scene tree for the first time.
func init(player_index, player_color):
	self.player_index = player_index
	self.player_color = player_color
	self.set_color(Party.available_colors[player_color])
	var spi = str(player_index)
	move_left = "move_left_" + spi
	move_right = "move_right_" + spi
	move_up = "move_up_" + spi
	move_down = "move_down_" + spi
	action_a = "action_a_" + spi
	action_b = "action_b_" + spi


func _process(delta):
	if not crash_mode:
		if self.active:
			if Input.is_action_pressed(move_left):
				self.move_and_collide(Vector2.LEFT*h_speed)
			
			if Input.is_action_pressed(move_right):
				self.move_and_collide(Vector2.RIGHT*h_speed)
			
			if Input.is_action_pressed(action_a):
				self.move_and_collide(Vector2.DOWN*break_speed)
			else:
				self.move_and_collide(Vector2.UP*up_speed)
	else:
		self.move_and_collide(Vector2.DOWN*crash_speed)
		self.rotate(rotation_speed*delta)
		current_crash_mode_cooldown -= delta
		
		if current_crash_mode_cooldown < 0:
			exit_crash_mode()
	
	current_time += delta
	while current_time > dust_partice_interval:
		var dust_particle_1 = dust_particle_effect.instance()
		var dust_particle_2 = dust_particle_effect.instance()
		var dust_particle_3 = dust_particle_effect.instance()
		var dust_particle_4 = dust_particle_effect.instance()
		dust_particle_1.position = self.position
		dust_particle_2.position = self.position
		dust_particle_3.position = self.position
		dust_particle_4.position = self.position
		
		dust_particle_1.position.x -= 32
		dust_particle_1.position.y += 32
		dust_particle_2.position.x += 32
		dust_particle_2.position.y += 32
		dust_particle_3.position.x -= 32
		dust_particle_3.position.y -= 24
		dust_particle_4.position.x += 32
		dust_particle_4.position.y -= 24
		
		$DustParticles.add_child(dust_particle_1)
		$DustParticles.add_child(dust_particle_2)
		$DustParticles.add_child(dust_particle_3)
		$DustParticles.add_child(dust_particle_4)
		current_time -= dust_partice_interval
		
# enter_crash_mode
# enters crash mode, which means that the player looses control of the vehicle
# and the vehicle starts going down
func enter_crash_mode():
	crash_mode = true
	current_crash_mode_cooldown = crash_mode_cooldown

# exit_crash_mode
# exits crash mode, the player regains control of the vehicle
func exit_crash_mode():
	crash_mode = false
	self.rotation = 0

# _on_Area2D_body_entered: KinematicBody2D
# destroys the body that entered the area and enters crash mode
func _on_Area2D_body_entered(body):
	var audio_manager = get_node("/root/AudioManager")
	$CollsionAudioSFX.play()
	
	enter_crash_mode()
	body.queue_free()

# getter
func get_name():
	return	"Player " + str(self.player_index)

func get_index():
	return	self.player_index

# setters
# set_color: Color -> None
func set_color(new_color):
	$Sprite.modulate = new_color

func set_active(new_active):
	self.active = new_active

