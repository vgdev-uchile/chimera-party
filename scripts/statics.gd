class_name Statics
extends Node

enum Inputs {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	A,
	B
}

class PlayerData:
	var input: int
	var primary_color: Color = Color.WHITE
	var secondary_color: Color
	var score: int
	var local_score: int
