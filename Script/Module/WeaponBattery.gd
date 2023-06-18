"""武器平台, 继承模块基类"""
class_name WeaponBattery extends ModuleBase
onready var random = RandomNumberGenerator.new()	# 随机数生成器

"""外部属性"""
# 攻击
export (PackedScene) var bullet				# 子弹
export var CD:int = 50
export var firing_count:int = 1			# 连续射击次数
export var firing_CD:int = 1			# 连续射击的间隙
export var firing_accuracy:float = 1.0	# 精度

export var rotation_speed:float = 0			# 旋转速度
export var attack_range:float = 0			# 攻击距离
export var attack_angle:float = PI/2		# 攻击角度

"""内部属性"""
var cur_cd:int = 0
var cur_firing_cd:int = 0
var cur_firing_count:int = 0	# 当前射击次数

# 外部接口
var target_manager:TargetManager = TargetManager.new()	# 攻击目标管理器
var move_inf:MoveInf = MoveInf.new()					# 移动接口
var faction_inf:FactionInf = FactionInf.new()			# 阵营操作接口

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
					target_manager.attack_target, myowner)# 发射信号
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
# 处理攻击
func process_attack(delta):
	if not do_attack_pre(delta):
		return
	if not do_attack(delta):
		return
	do_attack_post(delta)

# 执行攻击前置
func do_attack_pre(delta):
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

func do_attack_post(delta):
	return true

"""渲染函数"""
func _ready():
	add_to_group("weapon_battery")	# 将自己的节点列为武器平台分组

func _process(delta):
	# 减攻击cd
	if cur_cd > 0:
		cur_cd -= 1
	# 有目标则执行攻击
	if is_instance_valid(target_manager.attack_target):
		process_attack(delta)
	target_manager.update_target()
	
"""事件函数"""
#检测到单位进入
func _on_Detect_body_entered(body):
	# 自己和友军忽略
	if faction_inf.is_friendly(faction, body.faction):
		return
	# 检查类型
	match body.collision_layer:
		GlobalValue.LAYER_SHIP, GlobalValue.LAYER_CRAFT, \
		GlobalValue.LAYER_MISSILE, GlobalValue.LAYER_MODULE:	# 船, 飞行器, 导弹, 模块
			target_manager.add_target(body, true)

# 检测到单位退出, 删除目标
func _on_Detect_body_exited(body):
	# 自己和友军忽略
	if faction_inf.is_friendly(faction, body.faction):
		return
	target_manager.remove_target(body)
