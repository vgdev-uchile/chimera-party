extends Entity


onready var Players = get_node("../Players")
var players
var players_index = []
var closest_player = {"distance": 9223372036854775807, "player_index": -1}
var npc_vel = Vector2(0, 0)
var linear_vel = Vector2(0, 0)
onready var navigator = get_node("../Navigation2D")
var path = []
var death_players = []
var target = false
var started = false
var ended = false
var anim_cd = 50

func _ready():
	SPEED = 1
	damage = 1
	type = "owlBear"
	state = "sleep"
	$anim_sprite.play("sleep")

func _physics_process(delta):
	get_players()
	match state:
		"moving":
			state_moving()
		"cutscene":
			state_cutscene()
		"sleep":
			state_sleep()


func state_moving():
	animation_update()
		
	if started && not target:
		target = true
		get_closest_player_path()	
		
	elif path.size() > 0:
		var d = position.distance_to(path[0])
		if d > 1:
			npc_movement(path[0])						
		else:
			path.remove(0)
		
	elif target: # Small distance between player and owl, but not enough to kill him
		npc_movement(players[closest_player["player_index"]].position)
		get_closest_player_path()
		

func get_closest_player_path():
	# get closest player
	$attack.play()
	closest_player["distance"] = 9223372036854775807
	closest_player["player_index"] = 10
	players_index.shuffle()
	for i in players_index:
		if players[i].state != "dead":
			var distance = players[i].get_global_position().distance_to(position)
			if distance < closest_player["distance"]:
				closest_player["distance"] = distance
				closest_player["player_index"] = i
	if closest_player["player_index"] == 10:
		path = navigator.get_simple_path(position, position, true)
	else:
		path = navigator.get_simple_path(position, players[closest_player["player_index"]].position, true)
	return path


func npc_movement(point):
	npc_vel = position.direction_to(point) * SPEED
	linear_vel = lerp(linear_vel, npc_vel, 0.2)
	
	var collision = move_and_collide(linear_vel)

	if collision:
		if collision.collider.is_in_group("Entities") && target:
			
			anim_cd = 50
			$anim_sprite.play("attack_" + get_direction())
			
			match collision.collider.type:
				"player":
					if not death_players.has(collision.collider.player_index):
						golem_phase_two()
						death_players.append(collision.collider.player_index)
						collision.collider.set_state("dead")
						collision.collider.take_damage(self)
						if collision.collider.player_index == closest_player["player_index"]:
							target = false
							closest_player["distance"] = 9223372036854775807
							closest_player["player_index"] = 10
				"plank":
					var plank_dmg = collision.collider.take_damage(self)

func animation_update():
	anim_cd -= 1
	if anim_cd <= 0:
		$anim_sprite.play("walk_" + get_direction())
		anim_cd = 50
	
func get_direction():
	var direction = floor(rad2deg(linear_vel.angle_to(Vector2(0,1))))
	if 45 < direction  && direction < 135:
		return "right"
	elif (135 <= direction && direction < 181) || (-181 < direction && direction <= -135):
		return "up"
	elif -135 < direction && direction < -46:
		return "left"
	else:
		return "down"
	
	
func get_players():
	if !started:
		players = Players.get_children()
		players_index = range(Players.get_child_count())
		if Players.get_child_count() > 1:
			started = true

func _on_PreparationTimer_timeout():
	$anim_sprite.play("rise")
	state = "cutscene"	
	anim_cd = 500
	$rise.play()
	$action_timer.start()
	

func game_over():
	state = "cutscene"	
	$anim_sprite.modulate = Color("#ffffff")
	$anim_sprite.play("fall")
	anim_cd = 100
	ended = true

func golem_phase_two():
	$attack.play()
	SPEED = 5
	$anim_sprite.modulate = Color("#f31616")

func state_sleep():
	$anim_sprite.stop()

func state_cutscene():
	if anim_cd <= 0:
		$anim_sprite.stop()
		state = "sleep"
	anim_cd -= 1

func _on_action_timer_timeout():
	if !ended:
		state = "moving"
		$anim_sprite.play("walk_down")



func _on_Phase2Timer_timeout():
	golem_phase_two()
