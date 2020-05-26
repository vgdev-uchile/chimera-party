extends KinematicBody2D


export var SPEED: float = 500
var linear_vel = Vector2()

var player_index
var player_color

# Inputs
var move_left = ""
var move_right = ""
var move_up = ""
var move_down = ""
var action_a = ""
var action_b = ""

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

func _physics_process(delta):
	var target_vel = Vector2(Input.get_action_strength(move_right) - Input.get_action_strength(move_left),
	Input.get_action_strength(move_down) - Input.get_action_strength(move_up)) * SPEED
	
	linear_vel = lerp(linear_vel, target_vel, 0.2)
	move_and_slide(linear_vel)

func _process(delta):
	pass

# get_max_price_in_basket: None -> Price
# gets the price with the most value in the basket
func get_max_price_in_basket():
	var prices = self.get_prices_in_basket()
	var max_price = null
	for i in range(prices.size()):
		var price = prices[i]
		if max_price == null:
			max_price = price
		elif price.get_value() > max_price.get_value():
			price = max_price
	
	return max_price

# get_prices_in_basket: None -> Array(Price)
# gets the prices inside the basket
func get_prices_in_basket():
	return $CatchedObjectCollision.get_overlapping_bodies()
	
func get_player_index():
	return player_index
	
	
	
	
	
