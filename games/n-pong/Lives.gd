extends RichTextLabel

var field


func _process(delta):
	var bbtext = ""
	var players = field.players()
	for player in players:
		bbtext += player_bbtext(player)
		bbtext += "\n"
	update_bbtext(bbtext)


func player_bbtext(player):
	return "[color=#" + player.color().to_html(false) + "]" + str(player.lives) + "[/color]"


func update_bbtext(new_bbtext):
	if new_bbtext != bbcode_text:
		bbcode_text = new_bbtext
