class_name Chimerin
extends CharacterBody2D

var speed = 500
var acceleration = 1000
var input = 0

var data: Statics.PlayerData

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var pivot: Node2D = $Pivot
@onready var body_sprite: Sprite2D = $Pivot/BodySprite
@onready var label: Label = $Label



func _ready() -> void:
	animation_tree.animation_finished.connect(_on_animation_finished)
	animation_tree.active = true


func _physics_process(delta: float) -> void:
	var move_input = Input.get_vector(
		"move_left_%d" % input,
		"move_right_%d" % input,
		"move_up_%d" % input,
		"move_down_%d" % input)
	var target_velocity = speed * move_input
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	move_and_slide()


	# animation
	
	if move_input.length() > 0.01:
		animation_tree.set("parameters/idle/blend_position", move_input)
		animation_tree.set("parameters/walk/blend_position", move_input)
	
	if velocity.length() > 50 or (playback.get_current_node() == "walk" and target_velocity.length() > 50):
		playback.travel("walk")
	else:
		playback.travel("idle")

func _on_animation_finished(anim_name: StringName):
	if anim_name == "idle":
		animation_tree.set("parameters/idle/BlendTree/TimeScale/scale", 1/randf_range(1, 3))


# Call after add_child
func setup(player_data: Statics.PlayerData) -> void:
	data = player_data
	input = player_data.input
	change_color(player_data.primary_color)
	label.text = player_data.name


func change_color(color: Color):
	body_sprite.self_modulate = color
	for player in Game.players:
		if player.input == input:
			player.primary_color = color
