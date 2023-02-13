extends Node

@export_node_path("Node") var BEHAVIOR_PATH : NodePath = NodePath("../..")
@export var NAME : String

func get_behavior() -> Node:
	return get_node(BEHAVIOR_PATH)

func _process(delta : float):
	assert(false, "this function should be overloaded")
