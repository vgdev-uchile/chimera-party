extends RigidBody2D

export (int) var max_speed
export (int) var acceleration
export (int) var player_index
export (int, "Verde", "Rojo", "Amarillo", "Azul") var player_color
var score_counter = null
var move_left = ""
var move_right = ""
var move_up = ""
var move_down = ""
var action_a = ""
var action_b = ""


func init(player_index, player_color):
	self.player_index = player_index
	self.player_color = player_color
	$AnimatedSprite.modulate = Party.available_colors[player_color]
	var spi = str(player_index)
	move_left = "move_left_" + spi
	move_right = "move_right_" + spi
	move_up = "move_up_" + spi
	move_down = "move_down_" + spi
	action_a = "action_a_" + spi
	action_b = "action_b_" + spi
	$Light2D.color = ["00ff00", "ff0000", "ffff00", "0000ff"][player_color]

func get_move_direction():
	var dir_h = Input.get_action_strength(move_right) - Input.get_action_strength(move_left)
	var dir_v = int(Input.is_action_pressed(move_down)) - int(Input.is_action_pressed(move_up))
	return Vector2(dir_h, dir_v)

func _integrate_forces(state):
	var dir = get_move_direction()
	if dir.x != 0:
		$AnimatedSprite.scale.x = 3 * sign(dir.x)
	apply_central_impulse(dir * acceleration)

func _on_Moth_body_entered(body):
	if linear_velocity.length() > 150 and abs(linear_velocity.y) > 11:
		$HitSound.play()
	if body.has_method("switch") and body.on:
		body.switch(false)
		body.get_node("OffSound").play()
		body.controller.add_score(self, body.color)
		body.controller.start_timer()

func get_score():
	return score_counter.score
