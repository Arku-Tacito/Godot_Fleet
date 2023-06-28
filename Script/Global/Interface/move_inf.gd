"""移动相关的接口"""
"""要做成单例"""
extends Node

"""
求速度, 位置的接口
kinematicbody常用
"""
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

# 转向目标位置
# 返回角度绝对值
func turn_to_position(src_unit, dst_position:Vector2, rotation_speed:float, delta:float):
	var	angle = src_unit.get_angle_to(dst_position)
	var angle_delta = angle
	# 转向敌人
	if abs(angle) > PI/2:	# 控制下面的转向不要太大
		angle_delta = angle / 3
	src_unit.global_rotation += angle_delta * delta * rotation_speed
	return abs(angle)

# 瞄准目标, 考虑直线弹道
# 这里的目标要么是单位, 要么是可攻击的子弹
# 返回角度绝对值
func aim_at_target(src_unit, src_speed:float, attack_target, delta:float):
	# 获取目标的velocity
	var target_vel:Vector2 = Vector2.ZERO
	if attack_target is Unit:
		target_vel = attack_target.linear_velocity / 100
	elif attack_target is Missile:
		target_vel = attack_target.velocity * attack_target.speed
	# 计算迁移量
	var collision_pos = linear_trajectory(src_unit.global_position, src_speed,
													target_vel,
													attack_target.global_position)
	return turn_to_position(src_unit, collision_pos, src_unit.rotation_speed, delta)

"""
求力的接口
rigidbody常用
"""
# 根据移动位置求线性力, 不考虑重力, 依赖damp让物体停止运动
func update_linear_force_by_position(dst_p:Vector2, src_p:Vector2, linear_velocity:Vector2,
									max_force:float, max_speed:float, stop_distance:float, delta:float) -> Vector2:
	# 停止施加线性力
	var direction_dst:Vector2 = dst_p - src_p
	if direction_dst.length() < max(linear_velocity.length(), stop_distance):
		return Vector2.ZERO
	# 计算线性力方向
	var move_dir:Vector2 = direction_dst.normalized()
	if linear_velocity.length() > max_speed:
		move_dir += -1.5 * linear_velocity.normalized()
	var apply_force:Vector2 = move_dir.normalized() * max_force * delta
	return apply_force

# 根据角度求扭矩力, 不考虑当前旋转速度, , 依赖damp让物体停止旋转
func update_torque_force_by_degree(dst_d:float, src_d:float, max_torque_force:float,
									stop_rotation:float, delta:float) ->float:
	# 保持水平平衡
	var torque_force = max_torque_force * delta
	# 反向
	if src_d > dst_d:
		torque_force *= -1
	if abs(dst_d - src_d) > stop_rotation:
		return torque_force
	else:
		return 0.0
		
# 获取移动到目标的位置
func get_move_pos(dst_pos:Vector2, src_pos:Vector2, attack_range:float) -> Vector2:
	var ray:Vector2 = src_pos - dst_pos
	# 两个位置在垂直方向
	if ray.x == 0:
		if ray.y > 0:
			return Vector2(dst_pos.x, dst_pos.y + attack_range)
		else:
			return Vector2(dst_pos.x, dst_pos.y - attack_range)
	# 两个位置在水平方向
	if ray.y == 0:
		if ray.x > 0:
			return Vector2(dst_pos.x + attack_range, dst_pos.y)
		else:
			return Vector2(dst_pos.x - attack_range, dst_pos.y)
	# 从目标位置求y=ax的公式
	var a = ray.y / ray.x
	var x = pow(pow(attack_range, 2) / (1 + pow(a, 2)), 0.5)	# (1+a^2)x^2 = r^2
	if ray.x < 0:
		x *= -1
	return Vector2(dst_pos.x + x, dst_pos.y + a * x)
