extends Node2D

# TODO: PROPER POINTS ARRAY

const POINT_DENSITY : float = 0.2
const TIME : float = 0.05

func _process(delta : float):
	_process_curve(delta)

func _process_curve(delta : float):
	var lines : Array = get_children()
	var first_line : Line2D = lines.front()
	var last_lines : Array = lines.duplicate()
	last_lines.pop_front()
	# update point_count
	var origin : Vector2 = first_line.points[0]
	var target : Vector2 = first_line.points[first_line.points.size()-1]
	var new_point_count : int = max(2, round((origin-target).length() * POINT_DENSITY))
	if new_point_count > first_line.get_point_count():
		while(first_line.get_point_count() < new_point_count):
			first_line.add_point(first_line.get_point_position(first_line.get_point_count() - 1))
	elif new_point_count < first_line.get_point_count():
		while(first_line.get_point_count() > new_point_count):
			first_line.remove_point(first_line.get_point_count() - 1)
	# set point position
	for i in range(1, new_point_count - 1):
		first_line.set_point_position(i, first_line.get_point_position(i).lerp((first_line.get_point_position(i-1)+first_line.get_point_position(i+1))/2, delta/TIME))
	first_line.set_point_position(new_point_count - 1, target)
	# set all points
	for line in last_lines:
		line.points = first_line.points
