class_name Chimerin
extends CharacterBody2D


@export var speed = 500
@export var acceleration = 2000
var push_direction: Vector2 = Vector2.ZERO
var _pushers: Array[CharacterBody2D] = []
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var pivot: Node2D = $Pivot
@onready var body_sprite: Sprite2D = $Pivot/BodySprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var push_area: Area2D = $PushArea
@onready var pc: PlayerController = $PlayerController


func _ready() -> void:
	animation_tree.active = true
	push_area.body_entered.connect(_on_body_entered)
	push_area.body_exited.connect(_on_body_exited)
	pc.color_changed.connect(_on_color_changed)


func _physics_process(delta: float) -> void:
	var move_input = Input.get_vector(
		pc.move_left,
		pc.move_right,
		pc.move_up,
		pc.move_down)
	
	var direction = move_input
	push_direction = move_input
	
	# handle pushing
	for pusher in _pushers:
		var is_pushing = pusher.to_local(global_position).dot(pusher.push_direction) > 0
		if is_pushing:
			move_input += pusher.push_direction.project(global_position - pusher.global_position)

	var target_velocity = speed * move_input
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	move_and_slide()

	# animation
	if direction.length() > 0.01:
		animation_tree.set("parameters/idle/blend_position", direction)
		animation_tree.set("parameters/walk/blend_position", direction)
	
	if velocity.length() > 50 or (playback.get_current_node() == "walk" and target_velocity.length() > 50):
		playback.travel("walk")
	else:
		playback.travel("idle")


func setup(player_data: PlayerData) -> void:
	pc.setup(player_data)


func _on_color_changed(color: Color) -> void:
	body_sprite.self_modulate = color


func disable(value: bool, reset_animation: bool = true) -> void:
	set_physics_process(!value)
	playback.travel("idle")
	collision_shape_2d.set_deferred("disabled", value)
	if reset_animation:
		animation_tree.set("parameters/idle/blend_position", Vector2.DOWN)
		animation_tree.set("parameters/walk/blend_position", Vector2.DOWN)


func start_pushing(pusher: CharacterBody2D) -> void:
	_pushers.append(pusher)


func stop_pushing(pusher: CharacterBody2D) -> void:
	_pushers.erase(pusher)


func _on_body_entered(body: Node) -> void:
	if body != self and body.is_in_group("chimerin"):
		body.start_pushing(self)


func _on_body_exited(body: Node) -> void:
	if body != self and body.is_in_group("chimerin"):
		body.stop_pushing(self)
