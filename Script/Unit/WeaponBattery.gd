"""武器平台, 继承单位"""
class_name WeaponBattery extends UnitBase
onready var random = RandomNumberGenerator.new()	# 随机数生成器

"""外部属性"""
# 攻击
export (PackedScene) var bullet				# 子弹
export var CD = 50
export var firing_count = 1	# 连续射击次数
export var firing_CD = 1	# 连续射击的间隙
export var firing_accuracy = 1.0	# 精度
var cur_cd = 0
var cur_firing_cd = 0
var cur_firing_count = 0	# 当前射击次数

"""
生成弹药信号
bullet_obj 弹药类型
position 全局位置
rotation 全局方向, 会根据随机值偏移
target 攻击目标, 可为空
"""
signal firebullet(bullet_obj, position, rotation, target, owner)

"""辅助函数"""
# 发射一颗子弹
func fire_one_bullet(delta):
	if cur_firing_cd:
		cur_firing_cd -= 1
		return
	emit_signal("firebullet", bullet, 
					$Trigger.global_position, get_random_rotation(global_rotation, delta), 
					target_manager.attack_target, self)# 发射信号
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
# 执行攻击前置
func do_attack_pre(delta):
	if not .do_attack_pre(delta):
		return false
	# 被控制不需要自动转向
	if is_selected:	
		return true
	# 转向中不需要发射弹药
	if not is_selected and attack_angle < move_inf.aim_at_target(self, rotation_speed, target_manager.attack_target, delta):
		return false

	return true

# 执行攻击
func do_attack(delta):
	#.do_attack(delta)	# 武器平台不需要移动
	# 发射弹药
	if cur_firing_count:
		fire_one_bullet(delta)
		cur_firing_count -= 1
	if cur_cd == 0:
		cur_firing_count = firing_count
		cur_cd = CD
	return true

"""渲染函数"""
func _ready():
	add_to_group("weapon_battery")	# 将自己的节点列为武器平台分组

func _process(delta):
	if cur_cd > 0:
		cur_cd -= 1
