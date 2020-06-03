extends Entity


var linear_vel = Vector2()

var player_index
var player_color
var player_direction = "down"
var player_vel = Vector2(0, 0)
var plank_available = true

var anim_sprite 
 
# Inputs
var move_left = ""
var move_right = ""
var move_up = ""
var move_down = ""
var action_a = ""
var action_b = ""

func _ready():
	$pickaxe/anim.connect("animation_finished", self, "on_animation_finished")
	$pickaxe.connect("body_entered", self, "on_body_entered")
	$pickaxe.connect("body_entered", self, "on_tile_entered")

func init(player_index, player_color):
	SPEED = 200
	damage = 1
	type = "player"
	self.player_index = player_index
	self.player_color = player_color
	
	# Player of available color
	anim_sprite = get_node("../../PlayerAnimations/anim_player_" + str(player_color))
	anim_sprite.get_parent().remove_child(anim_sprite)
	add_child(anim_sprite)
	anim_sprite.position = Vector2.ZERO
	
	var spi = str(player_index)
	move_left = "move_left_" + spi
	move_right = "move_right_" + spi
	move_up = "move_up_" + spi
	move_down = "move_down_" + spi
	action_a = "action_a_" + spi
	action_b = "action_b_" + spi

func _physics_process(delta):
#	anim_sprite.position = position
	physics_update()
	match state:
		"moving":
			state_moving()
		"swinging":
			state_swinging()
		"dead":
			state_dead()
		"building":
			state_building()

func state_moving():
	player_vel = Vector2(Input.get_action_strength(move_right) - Input.get_action_strength(move_left),
	Input.get_action_strength(move_down) - Input.get_action_strength(move_up)) * SPEED
	
	if Input.is_action_pressed(move_left) and not Input.is_action_pressed(move_right):
		anim_sprite.play("walk_left")
		player_direction = "left"

	elif Input.is_action_pressed(move_right) and not Input.is_action_pressed(move_left):
		anim_sprite.play("walk_right")
		player_direction = "right"
		
	elif Input.is_action_pressed(move_down) and not Input.is_action_pressed(move_up):
		anim_sprite.play("walk_down")
		player_direction = "down"

	elif Input.is_action_pressed(move_up) and not Input.is_action_pressed(move_down):
		anim_sprite.play("walk_up")
		player_direction = "up"
	else:
		anim_sprite.play("iddle_" + player_direction)

	update_plank_position()
	
	match player_direction:
			"left":
				$pickaxe.rotation_degrees = 180
			"up":
				$pickaxe.rotation_degrees = 270
			"down":
				$pickaxe.rotation_degrees = 90
			"right":
				$pickaxe.rotation_degrees = 0
	
	if Input.is_action_just_pressed(action_a):
		$pickaxe/anim.play("swing")
		anim_sprite.play("attack_" + player_direction)
		state = "swinging"
	
	if Input.is_action_just_pressed(action_b) && plank_available:
		state = "building"
		$plank/anim.play("buildUp")
		$plank/anim_sprite.modulate = Color("#2dc3ab")
		$plank/anim_sprite.visible = true
		

func state_swinging():
	player_vel = Vector2(0, 0)

func state_dead():
	linear_vel += (position).normalized()*100
	anim_sprite.play("die")
	
func state_building():
	player_vel = Vector2(0, 0)
	
	var query = Physics2DShapeQueryParameters.new()
	query.set_transform(Transform2D($plank.transform[0], $plank.transform[1], $plank.transform[2] + transform[2]))
	query.set_shape($plank/collider.shape)
	var results = get_world_2d().direct_space_state.intersect_shape(query)
	if results.size() > 1:
		$plank/anim.play("buildUpX")
		$plank/anim_sprite.modulate = Color("#bb2323")
	
	elif Input.is_action_just_pressed(action_b):
		$plank.players_collisions_exception(false)
		plank_available = false
		$plank/anim.play("build")
		$plank/anim_sprite.modulate = Color("#ffffff")
		var plank = get_node("plank")
		var plank_original_pos = plank.global_position
		remove_child(plank)
		get_node("../../Planks").add_child(plank)
		plank.global_position = plank_original_pos
		state = "moving"

	if Input.is_action_just_pressed(action_a):
		$plank/anim_sprite.visible = false
		$plank/anim.play("death")
		state = "moving"

func on_animation_finished(anim_name):
	state = "moving"
	
func physics_update():
	linear_vel = lerp(linear_vel, player_vel, 0.2)
	linear_vel = move_and_slide(linear_vel)
	
func on_body_entered(body:Node):
	if body.is_in_group("Entities"):
		body.take_damage(self)
		
func on_tile_entered(area:Node2D):
	var query = Physics2DShapeQueryParameters.new()
	query.set_transform(Transform2D($pickaxe.transform[0], $pickaxe.transform[1], transform[2]))
	query.set_shape($pickaxe/CollisionShape2D.shape)
	var results = get_world_2d().direct_space_state.intersect_shape(query)
	for r in results:
		if r["collider"] is TileMap:
			var cell_pos = r["metadata"]
			$soft_rock_hit.play()
			r["collider"].set_cellv(cell_pos, 0)
	
	
func take_damage(entity):
	if entity.type != "player":
		$audio_dead.play()
		health -= entity.damage
	if health <= 0:
		$anim.play("death")
	else:
		linear_vel += (position - entity.position).normalized()*1000

func update_plank_position():
	if plank_available:
		match player_direction:
			"up":
				$plank.position = Vector2(0, -80)
			"down":
				$plank.position = Vector2(0, 80)
			"left":
				$plank.position = Vector2(-80, 0)
			"right":
				$plank.position = Vector2(80, 0)
		
func set_state(string):
	state = string

func _on_anim_animation_finished(anim_name):
	match anim_name:
		"death":
			state = "dead"


