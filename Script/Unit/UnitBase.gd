"""单位基类, 继承KinematicBody2D"""
class_name UnitBase extends KinematicBody2D

"""常量与枚举定义"""
enum STATUS {IDLE, DIE, ATTACK, HIT, MOVE}	# 状态类型

"""外部属性"""
# 基础
export var health:float = 200				# 血量
export var speed:float = 0					# 移动速度
export var rotation_speed:float = 0			# 旋转速度
export var attack_range:float = 0			# 攻击距离
export var attack_angle:float = PI/2		# 攻击角度

# 控制
export var faction:int = GlobalValue.FACTION_UNKNOWN	# 阵营
export var is_selected:bool = false			# 是否被选中

"""内部属性"""
# 状态
var status:int = STATUS.IDLE				# 基础状态
var velocity:Vector2 = Vector2.ZERO			# 当前速度向量
var rotation_dir:float = 0					# 当前旋转角度
var myowner:UnitBase = null					# 所属

var destination:Vector2	= global_position	# 移动目标位置

# 外部接口
var target_manager:TargetManager = TargetManager.new()	# 攻击目标管理器
var move_inf:MoveInf = MoveInf.new()					# 移动接口
var faction_inf:FactionInf = FactionInf.new()			# 阵营操作接口

# 效果
export (PackedScene) var effect_explosion	# 爆炸效果
signal explode(eff_obj, position, rotation)	# 爆炸信号

var is_flip:bool = false	# 翻转

"""接口函数"""
# 判断是否已经死亡
func is_dead():
	return status == STATUS.DIE

# 设置阵营
func set_faction(new_faction:int):
	faction = new_faction

# 承受伤害
func take_damage(from:UnitBase, hit_point:float):
	health -= hit_point
	if health <= 0:
		health = 0
		status =  STATUS.DIE
	# TODO: 增加经验

"""状态执行函数"""
# 处理idle
func process_idle(delta):
	if health <= 0:
		status = STATUS.DIE
		return
	if is_instance_valid(target_manager.attack_target):
		status = STATUS.ATTACK
		return
	else:
		target_manager.update_target()

## 处理移动
#func process_move(delta):
#	if velocity == Vector2.ZERO:
#		status == STATUS.IDLE
#		return
#	move_and_slide(velocity * speed)

# 处理攻击
func process_attack(delta):
	if not do_attack_pre(delta):
		return
	if not do_attack(delta):
		return
	do_attack_post(delta)

func do_attack_pre(delta):
	# 当前目标失效, 回到idle状态
	if not is_instance_valid(target_manager.attack_target):
		target_manager.update_target()
		status = STATUS.IDLE
		velocity = Vector2.ZERO
		return false
	# 目标有效, 继续执行攻击
	return true

func do_attack(delta):
	# 有目标, 更新速度
	var velocity_nor = move_inf.update_velocity_by_target(target_manager.attack_target.global_position,
										global_position,
										velocity,
										speed, rotation_speed,
										attack_range)
	velocity = velocity_nor * speed
	return true

func do_attack_post(delta):
	return true

# 处理承受伤害, 这里不是计算伤害的地方, 主要用于播放动画
func process_hit(delta):
	pass

# 处理死亡
func process_die(delta):
	if effect_explosion:	# 爆炸效果
		emit_signal("explode", effect_explosion, global_position, global_rotation)
	queue_free()
	
func do_flip():
	var nodes = get_children()
	for node in nodes:
		node.position.x = -1 * node.position.x
		if node is Sprite:
			node.set_flip_h(!node.flip_h)
		if node is CollisionPolygon2D:
			node.scale.x = -1 * node.scale.x
	is_flip = !is_flip
	
# 所有状态都会走的逻辑
func process_all(delta):
	if velocity != Vector2.ZERO:
		if (velocity.x < 0 and not is_flip) or (velocity.x > 0 and is_flip):
			do_flip()
		#move_inf.turn_to_position(self, global_position + velocity * delta, self.rotation_speed, delta)	# 转向速度方向
		move_and_slide(velocity)

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
			process_idle(delta)
		STATUS.ATTACK:
			process_attack(delta)
		STATUS.DIE:
			process_die(delta)
		STATUS.HIT:
			process_hit(delta)
	process_all(delta)

"""渲染函数"""
# 注意, 父类会被隐式调用
func _ready():
	add_to_group("unit_base")	# 将自己的节点列为单位
	# 阵营所属
	if is_instance_valid(myowner):
		faction = myowner.faction
	# 子模块也同样的阵营标志, 和所属
	for child in get_children():
		if "module_base" in child.get_groups():
			child.faction = faction
			child.myowner = self

func _process(delta):
	input_process()
	status_process(status, delta)

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

