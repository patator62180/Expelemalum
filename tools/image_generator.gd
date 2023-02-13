@tool
extends EditorScript

func _run() -> void:
#	_generate_pixel(Color.white)
	_generate_circle(100 / 0.15, Color.WHITE, 0.75)
#	_generate_circle(100, Color.WHITE, 0.25)
#	_generate_arc(750, 0.05 * PI, Color.white)

# generate

func _generate_pixel(color : Color):
	# draw
	var image : Image = _create_image(1, 1, color)
	# save
	var image_save_path : String = "res://tools/pixel.png"
	image.save_png(image_save_path)
	print("image generated: " + image_save_path)

func _generate_circle(radius : int, color : Color, distance_power : float = 0.0):
	# draw
	var image : Image = _create_image(2 * radius + 1, 2 * radius + 1)
	_draw_circle(image, radius, Color.WHITE, distance_power)
	image.generate_mipmaps()
	# save
	var image_save_path : String = "res://tools/circle_" + str(radius) + ".png"
	image.save_png(image_save_path)
	print("image generated: " + image_save_path)

func _generate_arc(radius : int, angle :float, color : Color):
	# draw
	var image : Image = _create_image(radius, 2 * sin(0.5 * angle) * radius)
	_draw_arc(image, radius, angle, Color.WHITE)
	image.generate_mipmaps()
	# save
	var image_save_path : String = "res://tools/arc_" + str(radius) + "_" + str(snapped(angle/PI, 0.01)).replace(".", "") + ".png"
	image.save_png(image_save_path)
	print("image generated: " + image_save_path)

# create

func _create_image(w : int, h : int, color : Color = Color.TRANSPARENT) -> Image:
	var image : Image = Image.new()
	image = Image.create(w, h, true, Image.FORMAT_RGBA8)
	image.fill(color)
	return image

# draw

func _draw_circle(image : Image, radius : int, color : Color, distance_power : float = 0.0) -> void:
	#image.lock()
	var center_x : int = image.get_width() / 2
	var center_y : int = image.get_height() / 2
	var center : Vector2 = Vector2(center_x, center_y)
	for i in range(center_x - radius, center_x + radius):
		for j in range(center_y - radius, center_y + radius):
			var r : Vector2 = Vector2(i, j) - center
			var r_length_squared : float = r.length_squared()
			var r_length : float = sqrt(r_length_squared)
			if r_length_squared < radius * radius:
				color.a = pow(min((radius - r_length)/radius, 1.0), distance_power)
				image.set_pixel(i, j, color)
	#image.unlock()

func _draw_arc(image : Image, radius : int, angle : float, color : Color) -> void:
	#image.lock()
	var center_x : int = 0
	var center_y : int = image.get_height() / 2
	var center : Vector2 = Vector2(center_x, center_y)
	for i in range(center_x - radius, center_x + radius):
		for j in range(center_y - radius, center_y + radius):
			var v : Vector2 = Vector2(i, j) - center
			if v.length_squared() < radius * radius and abs(v.angle()) < 0.5 * angle:
				image.set_pixel(i, j, color)
	#image.unlock()
