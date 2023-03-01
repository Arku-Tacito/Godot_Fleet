"""武器平台"""
extends KinematicBody2D

enum STATUS {IDLE, DIE, ATTACK, HIT, MOVE}	# 状态类型

"""基础属性"""
export var health = 100		# 血量
export var speed = 10		# 移动速度
export var rotation_speed = 0	# 旋转速度
export var CD = 50
export var is_selected = false	# 是否被选中

var velocity = Vector2.ZERO	# 当前速度向量
var rotation_dir = 0	# 当前旋转角度
var cur_cd = 0
var status = STATUS.IDLE	# 基础状态

onready var trigger = $Trigger	# 子弹发射器

"""基础函数"""
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
	# 发射弹药
	if cur_cd == 0:
		if trigger:
			trigger.activate()
		cur_cd = CD
	do_attack_fin()

func do_attack_fin():
	status = STATUS.IDLE

# 计算伤害
func do_damage(attacker):
	if attacker == null:
		return

	# 切换状态
	status = STATUS.HIT
	# 计算伤害
	print_debug("承受伤害")
	pass

# 执行承受伤害, 这里不是计算伤害的地方, 主要用于播放动画
func do_hit(delta):
	pass

func do_die(delta):
	queue_free()
	
# 处理输入
func input_process():
	if not is_selected:
		return
	if Input.is_action_pressed("attack"):
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

## Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	input_process()
	status_process(status, delta)
	pass
