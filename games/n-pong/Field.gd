extends Node2D

var scene
var radius

func num_players():
	return scene.player_num
	
	
func players():
	return scene.Players.get_children()
	
	
func angle():
	return TAU / num_players()


func player_at(angle):
	var i = floor(fmod(angle + self.angle() * 0.5 + TAU, TAU) / self.angle())
	return scene.Players.get_child(i)


func _draw():
	for i in range(scene.player_num):
		var player = scene.Players.get_child(i)
		draw_circle_arc_poly(
				Vector2.ZERO,
				radius + 4 * scene.ball.radius,
				angle() * (i - 0.5),
				angle() * (i + 0.5),
				player.color().darkened(0.2))


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)


func unit_vector(angle):
	return Vector2(cos(angle), sin(angle))
