extends Node2D


# Declare member variables here. Examples:
var speed = 8


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.y += speed


func _on_AnimatedSprite_animation_finished():
	queue_free()
