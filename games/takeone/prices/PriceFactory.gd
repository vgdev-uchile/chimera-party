extends Node

var PoopPrice = preload("res://games/takeone/prices/PoopPrice.tscn")
var TrashPrice = preload("res://games/takeone/prices/TrashPrice.tscn")
var CarKeyPrice = preload("res://games/takeone/prices/CarKeyPrice.tscn")
var RubberDuckiePrice = preload("res://games/takeone/prices/RubberDuckiePrice.tscn")
var GoldChestPrice = preload("res://games/takeone/prices/GoldChestPrice.tscn")
var MoonAmulletPrice = preload("res://games/takeone/prices/MoonAmulletPrice.tscn")
var GoldenDidgeridooPrice = preload("res://games/takeone/prices/GoldenDidgeridooPrice.tscn")

var price_classes = [PoopPrice, TrashPrice, CarKeyPrice, RubberDuckiePrice, GoldChestPrice, MoonAmulletPrice, GoldenDidgeridooPrice]
var price_random = [1.0/8.0, 1.0/8.0, 1/8.0, 1/10.0, 1/40.0, 1/50.0, 1/150.0]
var total_value = 0
var rng = RandomNumberGenerator.new()


func _ready():
	total_value = 0
	for i in range(price_random.size()):
		total_value += price_random[i]
	rng.randomize()

func get_random_price():
	var roulette_random = rng.randf()*total_value
	
	for i in range(price_random.size()):
		roulette_random -= price_random[i]
		if roulette_random <= 0:
			return price_classes[i].instance()
