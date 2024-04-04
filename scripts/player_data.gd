class_name PlayerData
## Data for a player
##
## Holds all the info that a player might use.

## Emitted when [member local_score] changes.
signal local_score_changed(new_value)

signal primary_color_changed(new_value)

## Player's input id.[br]
## Used to setup it's input actions.[br]
## [i]Check project actions for more info.[/i]
var input: int

## Player's primary color.[br]
## Use it to change the color of your player's main body or accessory
var primary_color: Color = Color.WHITE:
	set(value):
		primary_color = value
		primary_color_changed.emit(primary_color)
## Player's secondary color.[br]
## Not currently used.
## @experimental
var secondary_color: Color
## Player's total score.[br]
## Shouldn't be modified by your game.
var score: int
## Score obtained this round.[br]
## Must be modified before calling [code]Game.end_game()[/code]
var local_score: int = 0:
	set(value):
		local_score = value
		local_score_changed.emit(local_score)
