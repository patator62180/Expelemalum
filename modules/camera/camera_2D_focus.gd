extends Camera2D

@export var ZOOM_MIN : float
@export var ZOOM_MAX : float
@export var ZOOM_MARGING : float
@export var REACTION_TIME : float

@onready
var target_pos : Vector2 = global_position
@onready 
var target_size : Vector2 = get_viewport_rect().size

func _process(delta):
	_set_target_pos_zoom()
	global_position += (target_pos - global_position) * delta / REACTION_TIME
	if (target_size != Vector2.ZERO) && (get_viewport_rect().size != Vector2.ZERO):
		var target_zoom : float = max(clamp(get_viewport_rect().size.x/target_size.x, ZOOM_MIN, ZOOM_MAX), clamp(get_viewport_rect().size.y/target_size.y, ZOOM_MIN, ZOOM_MAX))
		zoom += (Vector2(target_zoom, target_zoom) - zoom) * delta / REACTION_TIME

func _set_target_pos_zoom():
	var pos_min : Vector2 = Vector2(INF, INF)
	var pos_max : Vector2 = Vector2(-INF, -INF)
	var target_collision_shapes : Array = get_tree().get_nodes_in_group("camera_focus")
	if not target_collision_shapes.is_empty():
		# get target points
		var target_points : Array = []
		for target in target_collision_shapes:
			target = target as CollisionShape2D
			var shape : Shape2D = target.shape
			if shape is RectangleShape2D:
				target_points.append(target.global_transform * Vector2(shape.extents.x, shape.extents.y))
				target_points.append(target.global_transform * Vector2(-shape.extents.x, shape.extents.y))
				target_points.append(target.global_transform * Vector2(shape.extents.x, -shape.extents.y))
				target_points.append(target.global_transform * Vector2(-shape.extents.x, -shape.extents.y))
			elif shape is CircleShape2D:
				target_points.append(target.global_transform * Vector2(shape.radius, shape.radius))
				target_points.append(target.global_transform * Vector2(-shape.radius, shape.radius))
				target_points.append(target.global_transform * Vector2(shape.radius, -shape.radius))
				target_points.append(target.global_transform * Vector2(-shape.radius, -shape.radius))
		# compute position and zoom
		for target in target_points:
			target = target as Vector2
			# min
			if target.x < pos_min.x:
				pos_min.x = target.x
			if target.y < pos_min.y:
				pos_min.y = target.y
			# max
			if target.x > pos_max.x:
				pos_max.x = target.x
			if target.y > pos_max.y:
				pos_max.y = target.y
		# Setting camera position
		target_pos = 0.5 * (pos_max + pos_min)
		# Setting camera zoom
		target_size = pos_max - pos_min + Vector2(ZOOM_MARGING, ZOOM_MARGING)
