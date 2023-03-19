"""单位通用"""
extends KinematicBody2D

enum STATUS {IDLE, DIE, ATTACK, HIT, MOVE}	# 状态类型

"""属性"""
# 基础
export var is_selected = false	# 是否被选中
export var health = 200		# 血量
export var speed = 0		# 移动速度
export var rotation_speed = 5	# 旋转速度
export var faction = 0			# 阵营
var velocity = Vector2.ZERO	# 当前速度向量
var rotation_dir = 0	# 当前旋转角度
var status = STATUS.IDLE	# 基础状态

# 攻击
export var firing_range_distance = 1000

# 目标
var attack_target = null	# 攻击目标
var await_target_list = []			# 待攻击目标列表
var target_set = {}			# 当前攻击目标与待攻击目标集合,用于去重

# 效果
export (PackedScene) var effect_explosion	# 爆炸效果
signal explode(eff_obj, position, rotation)

#onready var trigger = $Trigger	# 子弹发射器
"""信号"""


"""辅助函数"""
# 往目标方向前进
func update_velocity_with_target(target_position:Vector2, delta):
	# 在攻击范围内, 不移动
	if (target_position - global_position).length() <= firing_range_distance:
		velocity = Vector2.ZERO
		return
	var line_velocity = (target_position - global_position).normalized() * speed	# 朝向目标的向量, 要用global
	var acceleration_velocity = (line_velocity - velocity).normalized() * rotation_speed	# 转向加速度
	velocity += acceleration_velocity * delta	# 更新速度
	velocity = velocity.normalized()			# 限制速率不会超过本身最大速率
	global_rotation = velocity.angle()			# 朝向跟着速度走

# 判断是否是友好正营, 当前直接判断相等
func _if_target_friendly(target_faction):
	return faction == target_faction

# 添加目标
func add_target(target:Node2D, front:bool, immediately=false):
	# 盟友和自己就不要算进去啦
	if target == self or _if_target_friendly(target.faction):
		return
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
func remove_target(target:Node2D):
	if attack_target == target:
		attack_target = null
	if target_set.has(target):
		target_set.erase(target)

# 更新目标
func update_target():
	if is_instance_valid(attack_target):	# 目标是有效的
		status = STATUS.ATTACK
		return
	target_set.erase(attack_target)# 集合中去掉记录
	if not await_target_list.empty():	# 更新下一个目标
		attack_target = await_target_list.pop_front()			# 目标队列第一个目标添加进来
	else:
		attack_target = null				# 当前无目标

"""状态执行函数"""
# 状态执行
func do_idle(delta):
	if health <= 0:
		status = STATUS.DIE
		return

	if velocity != Vector2.ZERO or rotation_dir:
		status = STATUS.MOVE
		return

func do_move(delta):
	if velocity == Vector2.ZERO:
		status == STATUS.IDLE
	pass

func do_attack(delta):
	if is_instance_valid(attack_target):
		update_velocity_with_target(attack_target.global_position, delta)
	else:
		do_attack_fin()

func do_attack_fin():
	velocity = Vector2.ZERO
	status = STATUS.IDLE

# 计算伤害
func do_damage(damage_point):
	# 切换状态
	status = STATUS.HIT
	# 计算伤害
	health -= damage_point
	if health <= 0:
		status = STATUS.DIE

# 执行承受伤害, 这里不是计算伤害的地方, 主要用于播放动画
func do_hit(delta):
	pass

func do_die(delta):
	if effect_explosion:	# 爆炸效果
		emit_signal("explode", effect_explosion, global_position, global_rotation)
	queue_free()
	
"""状态转换函数"""
# 处理输入
func input_process():
	if not is_selected:
		return
	if Input.is_action_pressed("attack") and status != STATUS.DIE:
		status = STATUS.ATTACK

# 状态转换
func status_process(cur_status, delta):
	match cur_status:
		STATUS.IDLE:
			do_idle(delta)
		STATUS.ATTACK:
			do_attack(delta)
		STATUS.DIE:
			do_die(delta)
		STATUS.MOVE:
			do_move(delta)
		STATUS.HIT:
			do_hit(delta)
	update_target()

"""渲染函数"""
# 注意, 父类会被隐式调用
func _ready():
	add_to_group("unit")	# 将自己的节点列为武器平台分组
	for child in get_children():
		if "unit" in child.get_groups():
			child.faction = faction

func _process(delta):
	input_process()
	status_process(status, delta)
	#global_position += velocity * speed * delta
	move_and_slide(velocity * speed)

"""事件函数"""
#检测到单位进入, 也要把area的连接进来，才能识别导弹
func _on_Detect_body_entered(body:Node2D):
	# 检查类型
	match body.collision_layer:
		1, 4, 6, 16:	# 船, 飞行器, 导弹, 模块
			add_target(body, true)

# 检测到单位退出, 删除目标
func _on_Detect_body_exited(body):
	remove_target(body)
