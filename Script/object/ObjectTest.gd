extends Node2D

var chara: ObjectBase
var target: ObjectBase
# Called when the node enters the scene tree for the first time.
func _ready():
	chara = $Character
	target = $Target
	chara.update_dst_location(target.global_position)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	chara.update_dst_location(target.global_position)
