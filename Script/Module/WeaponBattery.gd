"""武器平台, 继承单位"""
extends "res://Script/Module/Unit_Common.gd"
onready var random = RandomNumberGenerator.new()	# 随机数生成器

"""属性"""
# 攻击
export (PackedScene) var bullet				# 子弹
export var firing_range_rotation = PI/2	# 可攻击范围
export var CD = 50
export var firing_count = 1	# 连续射击次数
export var firing_CD = 1	# 连续射击的间隙
export var firing_accuracy = 1.0	# 精度
var cur_cd = 0
var cur_firing_cd = 0
var cur_firing_count = 0	# 当前射击次数

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
# 计算击中提前量
func linear_trajectory(src_pos:Vector2, src_speed:float, dst_vel:Vector2, dst_pos:Vector2):
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
		print_debug("this_delta < 0")
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

# 转向敌人
func turning_to_fire(delta):
	if not is_instance_valid(attack_target):
		return false
	var not_to_fire = false
	# 计算迁移量
	var collision_pos = linear_trajectory(global_position, 1000,
													attack_target.velocity * attack_target.speed,
													attack_target.global_position)
	var	angle = self.get_angle_to(collision_pos)
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
					$Trigger.global_position, get_random_rotation(global_rotation, delta), 
					attack_target, self)# 发射信号
	cur_firing_cd = firing_CD
		
# 获取随机方向, 射击精度
func get_random_rotation(rotation:float, delta):
	var rotation_offset = 1.0 - firing_accuracy
	if !rotation_offset:
		return rotation
	else:
		var offset = random.randf_range(-1 * rotation_offset, rotation_offset)
		rotation += offset * delta * 10
		return rotation

"""状态执行函数"""
func do_attack(delta):
	# 如果在转向敌人, 转完退出
	if not is_selected and turning_to_fire(delta):
		return
	# 转向结束, 发射弹药
	if cur_firing_count:
		fire_one_bullet(delta)
		cur_firing_count -= 1
	if cur_cd == 0:
		cur_firing_count = firing_count
		cur_cd = CD
	do_attack_fin()
	
"""状态转换函数"""

"""渲染函数"""
func _ready():
	add_to_group("weapon_battery")	# 将自己的节点列为武器平台分组

func _process(delta):
	if cur_cd > 0:
		cur_cd -= 1

"""事件函数"""
