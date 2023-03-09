"""武器平台"""
extends KinematicBody2D

enum STATUS {IDLE, DIE, ATTACK, HIT, MOVE}	# 状态类型

"""基础属性"""
export var health = 200		# 血量
export var speed = 0		# 移动速度
export var rotation_speed = 5	# 旋转速度
export var firing_range_rotation = PI/2	# 攻击范围
export var CD = 50
export var is_selected = false	# 是否被选中

var velocity = Vector2.ZERO	# 当前速度向量
var rotation_dir = 0	# 当前旋转角度
var cur_cd = 0
var status = STATUS.IDLE	# 基础状态
var attack_target = null	# 攻击目标

export (PackedScene) var effect_explosion	# 爆炸效果
signal explode(eff_obj, position, rotation)

onready var trigger = $Trigger	# 子弹发射器

"""基础函数"""
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
	if cur_cd == 0:
		if trigger:
			trigger.activate(attack_target)
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
	
"""操作相关"""
	
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
	if is_instance_valid(attack_target):
		status = STATUS.ATTACK
	else:
		attack_target = null

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
