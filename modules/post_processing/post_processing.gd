@tool
extends Node

@export_range(-1.0, 1.0) var BRIGHTNESS : float:
	get:
		return BRIGHTNESS
	set(value):
		BRIGHTNESS = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("brightness", BRIGHTNESS)

@export_range(0.0, 3.0) var CONTRAST : float:
	get:
		return CONTRAST
	set(value):
		CONTRAST = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("contrast", CONTRAST)

@export_range(0.0, 3.0) var SATURATION : float:
	get:
		return SATURATION
	set(value):
		SATURATION = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("saturation", SATURATION)

@export_range(0.0, 1.0) var SATURATION_RED_FACTOR : float:
	get:
		return SATURATION_RED_FACTOR
	set(value):
		SATURATION_RED_FACTOR = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("saturation_red_factor", SATURATION_RED_FACTOR)

@export_range(0.0, 1.0) var SATURATION_GREEN_FACTOR : float:
	get:
		return SATURATION_GREEN_FACTOR
	set(value):
		SATURATION_GREEN_FACTOR = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("saturation_green_factor", SATURATION_GREEN_FACTOR)

@export_range(0.0, 1.0) var SATURATION_BLUE_FACTOR : float:
	get:
		return SATURATION_BLUE_FACTOR
	set(value):
		SATURATION_BLUE_FACTOR = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("saturation_blue_factor", SATURATION_BLUE_FACTOR)

@export var TINT_COLOR : Color:
	get:
		return TINT_COLOR
	set(value):
		TINT_COLOR = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("tint_color", TINT_COLOR)

@export var TINT_EFFECT_FACTOR : float:
	get:
		return TINT_EFFECT_FACTOR
	set(value):
		TINT_EFFECT_FACTOR = value
		if is_inside_tree():
			$CanvasLayer/ColorRect.material.set_shader_parameter("tint_effect_factor", TINT_EFFECT_FACTOR)

func _ready():
	set("BRIGHTNESS", BRIGHTNESS)
	set("CONTRAST", CONTRAST)
	set("SATURATION", SATURATION)
	set("SATURATION_RED_FACTOR", SATURATION_RED_FACTOR)
	set("SATURATION_GREEN_FACTOR", SATURATION_GREEN_FACTOR)
	set("SATURATION_BLUE_FACTOR", SATURATION_BLUE_FACTOR)
	set("TINT_COLOR", TINT_COLOR)
	set("TINT_EFFECT_FACTOR", TINT_EFFECT_FACTOR)
