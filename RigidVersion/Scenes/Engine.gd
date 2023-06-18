extends KinematicBody2D

func _ready():
	$Particles2D.emitting = false
	add_to_group("engine")
	
func call_flame(force:Vector2):
	if force.length() < 5:
		$Particles2D.emitting = false
	else:
		$Particles2D.emitting = true
	look_at(global_position + force)
