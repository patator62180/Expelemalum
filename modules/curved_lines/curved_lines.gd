extends Node2D

const POINT_DENSITY : float = 0.2
const TIME : float = 0.05

var origin : Node2D = null
var target : Node2D = null

func _process(delta : float):
	_process_curve(delta)

func _process_curve(delta : float):
	var lines : Array = get_children()
	var first_line : Line2D = lines.front()
	# set origin and target	
	first_line.set_point_position(0 , _get_relative_position(origin))
	first_line.set_point_position(first_line.points.size() - 1, _get_relative_position(target))
	# update point_count
	var new_point_count : int = max(2, round((_get_relative_position(origin)-_get_relative_position(target)).length() * POINT_DENSITY))
	if new_point_count > first_line.get_point_count():
		while(first_line.get_point_count() < new_point_count):
			first_line.add_point(first_line.get_point_position(first_line.get_point_count() - 1))
	elif new_point_count < first_line.get_point_count():
		while(first_line.get_point_count() > new_point_count):
			first_line.remove_point(first_line.get_point_count() - 1)
	# set point position
	for i in range(1, new_point_count - 1):
		first_line.set_point_position(i, first_line.get_point_position(i).lerp((first_line.get_point_position(i-1)+first_line.get_point_position(i+1))/2, delta/TIME))
	# set all points
	for i in range(1,lines.size()):
		lines[i].points = first_line.points

func _get_relative_position(node : Node2D):
	if node:
		return node.global_position - global_position
	else:
		return global_position
