extends Node2D

var _available = [true, true, true, true]

func set_available(value, index):
	_available[index] = value
	$AnimationTree.set("parameters/loop/conditions/available_" + str(index), value)


func set_keyset(keyset: String):
	$AnimationTree.active = false
	$AnimationPlayer.play(keyset)

func clear_ketset():
	$AnimationTree.active = true
