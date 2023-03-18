"""武器平台"""
extends KinematicBody2D

enum STATUS {IDLE, DIE, ATTACK, HIT, MOVE}	# 状态类型
onready var random = RandomNumberGenerator.new()	# 随机数生成器

"""属性"""
# 基础
export var is_selected = false	# 是否被选中
export var health = 200		# 血量
export var speed = 0		# 移动速度
export var rotation_speed = 5	# 旋转速度
var velocity = Vector2.ZERO	# 当前速度向量
var rotation_dir = 0	# 当前旋转角度
var status = STATUS.IDLE	# 基础状态

# 攻击
export (PackedScene) var bullet				# 子弹
export var firing_range_rotation = PI/2	# 可攻击范围
export var CD = 50
export var firing_count = 1	# 连续射击次数
export var firing_CD = 1	# 连续射击的间隙
export var bullet_rotation_range = 0.0 # 随机旋转范围, 正负范围
var cur_cd = 0
var cur_firing_cd = 0
var cur_firing_count = 0	# 当前射击次数

# 目标
var attack_target = null	# 攻击目标
var await_target_list = []			# 待攻击目标列表
var target_set = {}			# 当前攻击目标与待攻击目标集合,用于去重

# 效果
export (PackedScene) var effect_explosion	# 爆炸效果
signal explode(eff_obj, position, rotation)

#onready var trigger = $Trigger	# 子弹发射器
"""信号"""
"""
生成弹药信号
bullet_obj 弹药类型
position 全局位置
rotation 全局方向, 会根据随机值偏移
target 攻击目标, 可为空
"""
signal firebullet(bullet_obj, position, rotation, target, owner)

"""辅助函数"""
# 转向敌人
func turning_to_fire(delta):
	if not is_instance_valid(attack_target):
		return false
	var not_to_fire = false
	var angle = self.get_angle_to(attack_target.global_position)
	if abs(angle) > firing_range_rotation:	#在攻击角度外, 转向不射击
		not_to_fire = true
	# 转向敌人
	if abs(angle) > PI/2:	# 控制下面的转向不要太大
		angle /= 3
	global_rotation += angle * delta * rotation_speed
	return not_to_fire

# 发射
func fire_one_bullet(delta):
	if cur_firing_cd:
		cur_firing_cd -= 1
		return
	emit_signal("firebullet", bullet, 
					$Trigger.global_position, get_random_rotation($Trigger.global_rotation, delta), 
					attack_target, self)# 发射信号
	cur_firing_cd = firing_CD

# 添加目标
func add_target(target:Node2D, front:bool, immediately=false):
	# 自己就不要算进去啦
	if target == self:
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

# 更新目标
func update_target():
	if is_instance_valid(attack_target):	# 目标是有效的
		status = STATUS.ATTACK
		target_set.erase(attack_target)# 集合中去掉记录
	elif not await_target_list.empty():	# 更新下一个目标
		attack_target = await_target_list.pop_front()			# 目标队列第一个目标添加进来
	else:
		attack_target = null				# 当前无目标
		
# 获取随机方向
func get_random_rotation(rotation:float, delta):
	if !bullet_rotation_range:
		return rotation
	else:
		var offset = random.randf_range(-1 * bullet_rotation_range, bullet_rotation_range)
		rotation += offset * delta
		return rotation

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
	pass

func do_attack(delta):
	# 如果在转向敌人, 转完退出
	if turning_to_fire(delta):
		return
	# 转向结束, 发射弹药
	if cur_firing_count:
		fire_one_bullet(delta)
		cur_firing_count -= 1
	if cur_cd == 0:
		cur_firing_count = firing_count
		cur_cd = CD
	do_attack_fin()

func do_attack_fin():
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
	if cur_cd > 0:
		cur_cd -= 1
	update_target()

"""渲染函数"""
## Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("weapon_battery")	# 将自己的节点列为武器平台分组
	pass # Replace with function body.
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	input_process()
	status_process(status, delta)
	pass

"""事件函数"""
#检测到单位进入, 也要把area的连接进来，才能识别导弹
func _on_Detect_body_entered(body:Node2D):
	# 检查类型
	match body.collision_layer:
		1, 4:	# 单位, 飞行器
			add_target(body, false)
		6:			# 导弹优先解决
			add_target(body, true, true)
