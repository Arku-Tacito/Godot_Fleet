"""刚体单位类, 继承RigidBody"""
class_name Unit extends RigidBody2D 

"""运动属性"""
export var max_linear_force:float = 0			# 最大线性推力
export var max_torque_force:float = 0			# 最大扭矩力
export var max_linear_speed:float = 0			# 最大线性速率
export var stop_distance:float = 0				# 停止推动距离
export var stop_rotation:float = 0				# 停止旋转角度
export var is_vertical_balance:bool = true		# 是否保持垂直平衡
var move_pos:Vector2 = Vector2.ZERO				# 移动目标
var cur_linear_force:Vector2 = Vector2.ZERO		# 当前线性力
var cur_torque_force:float = 0					# 当前扭矩力

"""对战属性"""
export var health:float = 100							# 血量
export var faction:int = g_value.FACTION_UNKNOWN		# 阵营

"""信号"""
signal sig_deadbody(rigid_obj, position, rotation, impulse_torque_force, impulse_linear_force)	# 生成遗骸信号
signal sig_explode(explosion, position, rotation)	# 爆炸

"""移动函数"""
# 更新力
func update_force(delta):
	# 更新线性力
	cur_linear_force = move_inf.update_linear_force_by_position(move_pos, global_position, linear_velocity,
																max_linear_force, max_linear_speed, 
																stop_distance, delta)
	# 更新垂直平衡力
	if not is_vertical_balance:
		return
	cur_torque_force = move_inf.update_torque_force_by_degree(0, rotation_degrees,
																max_torque_force, stop_rotation, delta)

# 线性移动
func do_move():
	if cur_linear_force != Vector2.ZERO:
		apply_central_impulse(cur_linear_force)
	
# 垂直平衡
func do_vertical_balance():
	if cur_torque_force != 0:
		apply_torque_impulse(cur_torque_force)
		
"""状态更新函数"""
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
	emit_signal("sig_deadbody", null, global_position, global_rotation, cur_torque_force, cur_linear_force)
	emit_signal("sig_explode", null, global_position, global_rotation)

func _ready():
	add_to_group("unit")
	move_pos = global_position	# 默认在原点不移动
	# 将所有模块添加自己为所有者, 阵营相同
	for module in g_func.get_children_by_group(self, "module"):
		module.add_owner(self)
		module.faction = faction

func _physics_process(delta):
	update_force(delta)
	do_move()
	do_vertical_balance()
	update_status()
