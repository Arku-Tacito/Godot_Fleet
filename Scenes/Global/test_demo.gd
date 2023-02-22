extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Trigger_firebullet(bullet_obj, position, rotation, target):
	var bu = bullet_obj.instance()
	bu.position = position
	bu.rotation = rotation
	bu.velocity = bu.basic_velocity.rotated(bu.rotation)
	# bu.target = target
	bu.target = $Target/Target2		# 测试目标
	add_child(bu)
