class_name PlayerResource
extends Resource


enum PlayerInput {
	WASD_ZX             = 1 << 0,
	TFGH_VB             = 1 << 1,
	IJKL_NM             = 1 << 2,
	ARROWS_SHIFTCONTROL = 1 << 3,
}

@export var color: Color
@export var input: PlayerInput
