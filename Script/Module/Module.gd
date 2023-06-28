"""模块基类"""
class_name Module extends StaticBody2D

"""运动属性"""

"""对战属性"""
export var health:float = 100							# 血量
export var faction:int = g_value.FACTION_UNKNOWN		# 阵营

var myowner:Unit = null									# 所属单位

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
	return true

# 添加目标
func add_target(body):
	pass

# 移除目标
func remove_target(body):
	pass

"""状态更新函数"""
# 设置owner, 为其添加buff
func add_owner(owner:Unit):
	myowner = owner
	pass

# 去掉owner, 移除对应buff
func remove_owner():
	pass

# 处理受到伤害
func process_hit():
	pass

# 处理死亡
func process_die():
	queue_free()

func take_damage(damage_point):
	health -= damage_point
	if health < 0:
		health = 0
	process_hit()

func update_status():
	if health <= 0:
		process_die()

"""渲染函数"""
# 被销毁时, 生成爆炸和残骸效果
func _exit_tree():
	emit_signal("sig_explode", null, global_position, global_rotation)

func _ready():
	add_to_group("module")

func _physics_process(delta):
	update_status()

"""事件函数"""
func _on_Detect_body_entered(body):
	if check_target_type(body) and not is_friendly(body):
		add_target(body)

func _on_Detect_body_exited(body):
	remove_target(body)
