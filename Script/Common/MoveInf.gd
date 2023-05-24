"""移动相关的接口"""
extends Resource
class_name MoveInf
# 根据移动目标更新 velocity 并归一化
func update_velocity_by_target(target_pos:Vector2, cur_pos:Vector2, old_vel:Vector2, 
								speed:float, rotation_speed:float, stop_range:float=0) -> Vector2:
	# 在范围内, 停止
	if (target_pos - cur_pos).length() <= stop_range:
		return Vector2.ZERO
	var line_vel = (target_pos - cur_pos).normalized() * speed	# 朝向目标的向量, 要用global
	var acc_vel = (line_vel - old_vel).normalized() * rotation_speed		# 转向加速度
	var new_vel_nor = (old_vel + acc_vel).normalized()						# 更新速度
	
	return new_vel_nor

# 考虑直线弹道, 计算击中的坐标
func linear_trajectory(src_pos:Vector2, src_speed:float, dst_vel:Vector2, dst_pos:Vector2) -> Vector2:
	# 目标没有速度, 直接返回其坐标
	var dst_speed = dst_vel.length()			# 目标速率
	if dst_speed == 0:
		return dst_pos
	var distance = (src_pos - dst_pos).length()	# 两点距离
	var cos_theta = (src_pos - dst_pos).dot(dst_vel) / (distance * dst_speed)	# 目标的速度与到源的夹角cos值
	
	var a = 1 - pow(src_speed / dst_speed, 2)
	var b = -2 * distance * cos_theta
	var c = distance * distance
	
	# 求根公式delta
	var this_delta = b * b - 4 * a * c
	
	# 求根公式无解, 直接返回目标位置
	if this_delta < 0:
		# print_debug("this_delta < 0")
		return dst_pos
	
	# 解方程, F为碰撞时, 目标的位移
	var F1 = (-b + sqrt(this_delta)) / (2 * a)
	var F2 = (-b - sqrt(this_delta)) / (2 * a)
	var F = F1
	if F1 < F2:
		F = F2
	
	# 换算成碰撞点坐标
	var impact_point = dst_pos + F * dst_vel.normalized()
	return impact_point

# 瞄准目标, 考虑直线弹道
# 这里的目标要么是单位, 要么是可攻击的子弹
# 返回角度绝对值
func aim_at_target(src_unit, src_speed:float, attack_target, delta:float):
	# 计算迁移量
	var collision_pos = linear_trajectory(src_unit.global_position, src_speed,
													attack_target.velocity * attack_target.speed,
													attack_target.global_position)
	var	angle = src_unit.get_angle_to(collision_pos)
	var angle_delta = angle
	# 转向敌人
	if abs(angle) > PI/2:	# 控制下面的转向不要太大
		angle_delta = angle / 3
	src_unit.global_rotation += angle_delta * delta * src_unit.rotation_speed
	return abs(angle)
