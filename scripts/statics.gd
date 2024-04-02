class_name Statics
extends Node

enum Inputs {
	LEFT	= 1 << 0,
	RIGHT	= 1 << 1,
	UP		= 1 << 2,
	DOWN	= 1 << 3,
	A		= 1 << 4,
	B		= 1 << 5,
}

class PlayerData:
	var input: int
	var primary_color: Color = Color.WHITE
	var secondary_color: Color
	var score: int
	var local_score: int
