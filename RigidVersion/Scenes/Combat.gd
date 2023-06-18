extends Node2D

var child_list:Array = [] 

var once=false

func _ready():
	child_list = get_tree().get_nodes_in_group("unit")

func _process(delta):
	for unit in child_list:
		unit.move_pos = $Target.global_position
