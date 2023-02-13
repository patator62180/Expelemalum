@tool
extends EditorScript

const spawning_scene_path : String = "res://modules/character/peasants/lumberjack.tscn"
const parent_path : NodePath = NodePath("Playground")
const spawn_area_path : NodePath = NodePath("Boundary/CollisionShape2D")
const spawn_number : int = 32

func _run():
	var spawning_scene : PackedScene = load(spawning_scene_path)
	var parent : Node2D = get_scene().get_node(parent_path)
	var spawn_area : CollisionShape2D = get_scene().get_node(spawn_area_path)
	for i in range(spawn_number):
		var spawn : Node2D = spawning_scene.instantiate()
		parent.add_child(spawn)
		spawn.owner = get_scene()
		spawn.global_position.x = spawn_area.global_position.x + spawn_area.shape.extents.x * randf_range(-1.0, 1.0)
		spawn.global_position.y = spawn_area.global_position.y + spawn_area.shape.extents.y * randf_range(-1.0, 1.0)
