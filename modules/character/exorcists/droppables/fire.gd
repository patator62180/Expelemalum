extends Node2D

signal done

const APPEAR_TIME = 0.5
const DISAPPEAR_TIME = 1.0

const WIGGLE_STEP_ANGULAR_RANGE = 0.05 * TAU
const WIGGLE_STEP_DURATION = 0.1

func _on_fire_done():
	emit_signal("done")

func _ready():
	# tween
	var tween_appear : Tween = get_tree().create_tween().bind_node(self)
	var tween_wiggle : Tween = get_tree().create_tween().bind_node(self).set_loops()
	var sprites : Array = $Root.get_children()
	var first_sprite : Sprite2D = sprites.front()
	var last_sprites : Array = sprites.duplicate()
	last_sprites.pop_front()
	# appear
	for sprite in sprites:
		sprite = sprite as Sprite2D
		## scale
		tween_appear.parallel().tween_property(sprite, "scale", sprite.scale, APPEAR_TIME).set_trans(Tween.TRANS_CUBIC)
		sprite.scale.y = 0
		## position
		tween_appear.parallel().tween_property(sprite, "position", sprite.position, APPEAR_TIME).set_trans(Tween.TRANS_CUBIC)
		sprite.position.y = 0
	# disappear
	tween_appear.tween_property(first_sprite, "scale", Vector2(first_sprite.scale.x, 0), DISAPPEAR_TIME).set_trans(Tween.TRANS_CUBIC)
	tween_appear.parallel().tween_property(first_sprite, "position", Vector2(first_sprite.position.x, 0), DISAPPEAR_TIME).set_trans(Tween.TRANS_CUBIC)
	for sprite in last_sprites:
		sprite = sprite as Sprite2D
		tween_appear.parallel().tween_property(sprite, "scale", Vector2(sprite.scale.x, 0), DISAPPEAR_TIME).set_trans(Tween.TRANS_CUBIC)
		tween_appear.parallel().tween_property(sprite, "position", Vector2(sprite.position.x, 0), DISAPPEAR_TIME).set_trans(Tween.TRANS_CUBIC)
	#wiggle
	var wiggle_step_duration : float = WIGGLE_STEP_DURATION * randf_range(0.0, 1.0)
	var rotation_target : float = first_sprite.rotation + WIGGLE_STEP_ANGULAR_RANGE * randf_range(-1.0, 1.0)
	tween_wiggle.tween_property(first_sprite, "rotation", rotation_target, wiggle_step_duration).set_trans(Tween.TRANS_QUAD)
	for sprite in last_sprites:
		rotation_target = sprite.rotation + WIGGLE_STEP_ANGULAR_RANGE * randf_range(-1.0, 1.0)
		tween_wiggle.parallel().tween_property(sprite, "rotation", rotation_target, wiggle_step_duration).set_trans(Tween.TRANS_QUAD)
	rotation_target = first_sprite.rotation + WIGGLE_STEP_ANGULAR_RANGE * randf_range(-1.0, 1.0)
	tween_wiggle.tween_property(first_sprite, "rotation", rotation_target, 0.1).set_trans(Tween.TRANS_QUAD)
	for sprite in last_sprites:
		rotation_target = sprite.rotation + WIGGLE_STEP_ANGULAR_RANGE * randf_range(-1.0, 1.0)
		tween_wiggle.parallel().tween_property(sprite, "rotation", rotation_target, wiggle_step_duration).set_trans(Tween.TRANS_QUAD)
	rotation_target = first_sprite.rotation
	tween_wiggle.tween_property(first_sprite, "rotation", rotation_target, wiggle_step_duration).set_trans(Tween.TRANS_QUAD)
	for sprite in last_sprites:
		rotation_target = sprite.rotation
		tween_wiggle.parallel().tween_property(sprite, "rotation", rotation_target, wiggle_step_duration).set_trans(Tween.TRANS_QUAD)
	# free on animation
	tween_appear.tween_callback(queue_free)
	# timer
	$TimerSignalDone.wait_time = APPEAR_TIME
	$TimerSignalDone.start()
