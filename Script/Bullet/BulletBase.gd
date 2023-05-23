"""子弹基类"""
class_name BulletBase extends Area2D 

"""常量与枚举定义"""
const FACTION_UNKNOWN = -1					# 未知阵营

"""外部属性"""
export var speed:float = 500		 		# 速度
export var rotation_speed:float = 1.0		# 转向速度
export var life_time:int = 1000	 			# 基础存活时间
export var basic_damage:float = 5.0 		# 基础伤害
export var aoe_damage:float = 3.0			# 范围爆炸伤害
export var cross_level:int = 1				# 穿击等级, 撞击物体后是否继续前进
export var is_target_locked = false			# 是否锁定目标	

"""内部属性"""
var faction:int = FACTION_UNKNOWN	# 阵营
var target = null					# 攻击的目标
var myowner:UnitBase = null			# 所属
var is_stop:bool = false
var basic_velocity:Vector2 = Vector2.RIGHT
var velocity:Vector2 = Vector2.ZERO

# 外部接口
var target_manager:TargetManager = TargetManager.new()	# 攻击目标管理器
var faction_inf:FactionInf = FactionInf.new()			# 阵营操作接口

# 效果
export (PackedScene) var effect_explosion	# 爆炸效果
signal explode(eff_obj, position, rotation)

"""接口函数"""
# 生成前准备
func do_ready(new_position:Vector2, new_rotation:float, new_target, new_owner:UnitBase):
	position = new_position
	rotation = new_rotation
	velocity = basic_velocity.rotated(new_rotation)
	target_manager.add_target(new_target, false)
	myowner = new_owner
	faction = myowner.faction

"""辅助函数"""
# 执行爆炸
func do_explode():
	if effect_explosion:
		emit_signal("explode", effect_explosion, global_position, global_rotation)

# 降低击穿等级, 为0则等待销毁
func cross_level_decline():
	do_explode()			# 执行爆炸
	cross_level -= 1		# 击穿等级降低
	if cross_level <= 0:	# 无法再碰撞, 销毁
		queue_free()

# 更新移动
func update_movement(delta):
	# 停止
	if is_stop:
		return
	global_position += velocity * speed * delta

"""渲染函数"""
func _ready():
	add_to_group("bullet")	# 添加到子弹分组

func _physics_process(delta):
	if !life_time:
		queue_free()
	life_time -= 1
	update_movement(delta)

"""事件函数"""
# 撞击到物体
func _on_body_entered(body):
	# 盟友不算进去
	if is_instance_valid(myowner):
		if faction_inf.is_friendly(faction, body.faction):
			return
	match body.collision_layer:
		1, 4, 6, 16:	# 船, 飞行器, 导弹, 模块
			body.take_damage(myowner,basic_damage)	# 承受伤害
			cross_level_decline()	# 撞击一次降低一次击穿等级
