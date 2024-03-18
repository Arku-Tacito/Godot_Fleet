"""子弹基类"""
class_name Bullet extends Area2D 

"""运动属性"""
export var speed:float = 500		 		# 速度
export var rotation_speed:float = 1.0		# 转向速度

var velocity:Vector2 = Vector2.ZERO			# 速度向量

"""对战属性"""
export var health:float = 100							# 血量
export var life_time:int = 1000	 						# 基础存活时间
export var basic_damage:float = 5.0 					# 基础伤害
export var aoe_damage:float = 3.0						# 范围爆炸伤害
export var cross_level:int = 1							# 穿击等级, 撞击物体后是否继续前进

var faction:int = g_value.FACTION_UNKNOWN				# 阵营
var myowner:Unit = null									# 所属单位

# 外部接口
var target_manager:TargetManager = TargetManager.new()	# 攻击目标管理器

"""信号"""
signal sig_deadbody(rigid_obj, position, rotation, impulse_torque_force, impulse_linear_force)	# 生成遗骸信号
signal sig_explode(explosion, position, rotation)	# 爆炸

"""辅助函数"""
# 判断是否为友方
func is_friendly(target) -> bool:
	if not is_instance_valid(myowner) or not is_instance_valid(target):
		return true	# 无法判断, 默认算是
	return faction_inf.is_friendly(myowner.faction, target.faction)

# 检查目标类型
func check_target_type(body) -> bool:
	return (body is Unit) or (body is Module) #or (body is Bullet)
	
# 处理运动
func update_movement(delta):
	global_position += velocity * speed * delta

# 生成前准备
func do_ready(new_position:Vector2, new_rotation:float, new_target, new_owner:Unit):
	position = new_position
	rotation = new_rotation
	velocity = Vector2.RIGHT.rotated(new_rotation)
	target_manager.add_target(new_target, false)
	myowner = new_owner
	faction = myowner.faction

# 执行伤害
func do_damage(target, damage_point:float, need_free=false):
	target.take_damage(damage_point)	# 目标承受伤害
	if need_free:
		queue_free()

"""状态更新函数"""
# 处理伤害计算
func process_damage(target):
	var damage_point = basic_damage
	var need_free = false
	# 是攻击目标, 伤害后销毁
	if target == target_manager.attack_target:
		need_free = true
	# 中间击穿伤害减半
	elif cross_level > 0:
		damage_point *= 0.8
	cross_level -= 1		# 击穿等级降低
	if cross_level <= 0:	# 无法再碰撞, 销毁
		need_free = true
	do_damage(target, damage_point, need_free)

# 处理受到伤害
func process_hit():
	pass

# 处理死亡
func process_die():
	queue_free()

# 承受伤害
func take_damage(damage_point):
	health -= damage_point
	if health < 0:
		health = 0
	process_hit()

func update_status():
	if !life_time:
		queue_free()
	life_time -= 1
	if health <= 0:
		process_die()

"""渲染函数"""
# 被销毁时, 生成爆炸和残骸效果
func _exit_tree():
	emit_signal("sig_explode", null, global_position, global_rotation)

func _ready():
	add_to_group("bullet")

func _physics_process(delta):
	update_status()
	update_movement(delta)

"""事件函数"""
func _on_Detect_body_entered(body):
	print_debug()
	if check_target_type(body) and is_friendly(body):
		return
	process_damage(body)
