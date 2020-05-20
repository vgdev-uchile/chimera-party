tool

extends HBoxContainer


export var description : String = "" setget set_description
export var left : bool = false setget set_left
export var right : bool = false setget set_right
export var up : bool = false setget set_up
export var down : bool = false setget set_down
export var a : bool = false setget set_a
export var b : bool = false setget set_b

func set_description(new_value):
	$Description.text = new_value


func set_left(new_value):
	left = new_value
	$Inputs/Left.visible = left

func set_right(new_value):
	right = new_value
	$Inputs/Right.visible = right

func set_up(new_value):
	up = new_value
	$Inputs/UpDown/Up.visible = up
	if not down:
		$Inputs/UpDown.visible = up

func set_down(new_value):
	down = new_value
	$Inputs/UpDown/Down.visible = down
	if not up:
		$Inputs/UpDown.visible = down

func set_a(new_value):
	a = new_value
	$Inputs/A.visible = a
	
func set_b(new_value):
	b = new_value
	$Inputs/B.visible = b


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
