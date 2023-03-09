extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var angle_to = $MachineGun.global_position.angle_to($MachineGun2.global_position)
	var angle_to_point = $MachineGun.global_position.angle_to_point($MachineGun2.global_position)
	var angle = $MachineGun.get_angle_to($MachineGun2.global_position)
	print_debug(angle_to, angle_to_point, angle)
	pass
