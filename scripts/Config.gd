extends Resource
class_name Config

export var display_name: String
export(String, MULTILINE) var description

enum GameType {
	ALL_FOR_ALL,
	ONE_VS_TWO,
	ONE_VS_THREE,
	TWO_VS_TWO
}

export(GameType, FLAGS) var game_types = 1

export var control_group = false
export var cg_name_0: String
export var cg_name_1: String

export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_0 = 0
export var dir_desc_0: String
export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_1 = 0
export var dir_desc_1: String
export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_2 = 0
export var dir_desc_2: String
export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_3 = 0
export var dir_desc_3: String

export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_4 = 0
export var dir_desc_4: String
export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_5 = 0
export var dir_desc_5: String
export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_6 = 0
export var dir_desc_6: String
export(int, FLAGS, "Left", "Right", "Up", "Down") var dir_group_7 = 0
export var dir_desc_7: String

export(int, FLAGS, "A", "B") var act_group_0 = 0
export var act_desc_0: String
export(int, FLAGS, "A", "B") var act_group_1 = 0
export var act_desc_1: String
export(int, FLAGS, "A", "B") var act_group_2 = 0
export var act_desc_2: String
export(int, FLAGS, "A", "B") var act_group_3 = 0
export var act_desc_3: String
