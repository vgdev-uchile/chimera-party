extends Area2D

signal player_ready
signal game_ready

@onready var timer: Timer = $Timer
@onready var countdown: Label = $Countdown



func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process(false)
	timer.timeout.connect(_on_timeout)
	countdown.hide()


func _process(delta: float) -> void:
	countdown.text = str(ceil(timer.time_left))


func _on_body_entered(body: Node2D) -> void:
	if body is Chimerin:
		var player = body as Chimerin
		player_ready.emit(player.data, true)


func enable(value: bool) -> void:
	if timer.is_stopped() == not value:
		return
	set_process(value)
	countdown.visible = value
	if value:
		timer.start()
	else:
		timer.stop()


func _on_body_exited(body: Node2D) -> void:
	if body is Chimerin:
		var player = body as Chimerin
		player_ready.emit(player.data, false)


func _on_timeout():
	set_process(false)
	body_entered.disconnect(_on_body_entered)
	body_exited.disconnect(_on_body_exited)
	game_ready.emit()
