extends Line2D

const POINT_DENSITY : float = 0.1
const TIME : float = 0.05

func _process(delta : float):
	_process_curve(delta)


func _process_curve(delta : float):
	# update point_count
	var origin = points[0]
	var target = points[points.size()-1]
	var new_point_count : int = max(2, round((origin-target).length() * POINT_DENSITY))
	if new_point_count > get_point_count():
		while(get_point_count() < new_point_count):
			add_point(get_point_position(get_point_count() - 1))
	elif new_point_count < get_point_count():
		while(get_point_count() > new_point_count):
			remove_point(get_point_count() - 1)
	# set point position
	for i in range(1, new_point_count - 1):
		set_point_position(i, get_point_position(i).lerp((get_point_position(i-1)+get_point_position(i+1))/2, delta/TIME))
	set_point_position(new_point_count - 1, target)
