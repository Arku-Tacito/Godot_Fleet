"""导弹"""
class_name Missile extends Bullet 

# 处理运动
func update_movement(delta):
	# 跟踪目标
	if is_instance_valid(target_manager.attack_target):
		var velocity_nor = move_inf.update_velocity_by_target(
			target_manager.attack_target.global_position,
											global_position,
											velocity,
											speed, rotation_speed,
											0
		)
		velocity = velocity_nor * speed
	# 移动
	target_manager.update_target()
	global_rotation = velocity.angle()	# 转向
	global_position += velocity * delta

func _ready():
	add_to_group("missile")
