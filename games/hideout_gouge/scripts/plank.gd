extends Entity

var started = false
var players
var players_index
onready var Players = get_node("../../")

func _ready():
	health = 3
	type = "plank"

func _physics_process(delta):
	get_players()
	hitstun -= 1
	match state:
		"moving":
			state_moving()
		"death":
			state_death()

func take_damage(entity):
	if hitstun <= 0 || entity.type == "player":
		health -= entity.damage
		print(hitstun)
		if health <= 0:
			$destroyed.play()
			$anim.play("death")
			$anim_sprite.visible = false
			# kill crate
			state = "death"
			return "death"
		else:
			$anim_sprite.play("damage_" + str(3 - health))
			$soft_hit.play()
			hitstun = 200
			return "damaged"
	return "hitstun"

func play_death():
	state = "death"
	
func state_death():
	pass

func get_players():
	if !started:
		players = Players.get_children()
		players_index = range(Players.get_child_count())
		if Players.get_child_count() > 2:
			started = true
			players_collisions_exception(true)

func players_collisions_exception(enable):
	print(enable)
	match enable:
		true:
			for i in players_index:
				self.add_collision_exception_with(players[i])
		false:
			for i in players_index:
				self.remove_collision_exception_with(players[i])
