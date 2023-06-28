"""目标管理更新"""
class_name TargetManager extends Resource

"""属性"""
var attack_target = null						# 攻击目标
var await_target_list = []						# 待攻击目标列表
var target_set = {}								# 当前攻击目标与待攻击目标集合,用于去重

"""接口"""
# 目标是否有效(没有销毁或没有死亡) 看要不要用这个接口
func is_target_valid(target)->bool:
	if not is_instance_valid(target):
		return false
	elif target.is_dead():
		return false
	else:
		return true

# 添加目标
func add_target(target, front:bool, immediately=false):
	# 去重
	if target_set.has(target):
		return
	target_set[target] = true

	if immediately:
		# 如果要立即解决, 先把当前的target放队列
		if is_instance_valid(attack_target):
			await_target_list.push_front(attack_target)
		attack_target = target
	else:
		# 不需要立刻解决放队头或队尾
		if front:
			await_target_list.push_front(target)
		else:
			await_target_list.append(target)

# 删除目标
func remove_target(target):
	if attack_target == target:
		attack_target = null
	if target_set.has(target):
		target_set.erase(target)

# 更新目标, 返回是否有目标了
func update_target():
	# 目标是有效的
	if is_instance_valid(attack_target):
		return
	# 目标是无效的, 更新下一个
	target_set.erase(attack_target)# 集合中去掉记录
	if not await_target_list.empty():	# 更新下一个目标
		attack_target = await_target_list.pop_front() # 目标队列第一个目标添加进来
		return
	else:
		attack_target = null				# 当前无目标
