"""导弹基类"""
class_name MissileBase extends BulletBase

"""外部属性"""
export var health:float = 30				# 血量
export var is_target_locked = true			# 是否锁定目标	

"""内部属性"""
# 外部接口
var move_inf:MoveInf = MoveInf.new()					# 移动接口

"""接口函数"""
# 承受伤害
func take_damage(from:UnitBase, hit_point:float):
	health -= hit_point
	if health <= 0:
		do_explode()
		queue_free()

"""辅助函数"""
# 更新移动
func update_movement(delta):
	# 停止
	if is_stop:
		return
	# 跟踪目标
	if is_target_locked and is_instance_valid(target_manager.attack_target):
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

"""渲染函数"""
