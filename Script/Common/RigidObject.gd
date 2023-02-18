# 通用模块脚本, 拥有基础的状态转换逻辑和属性
extends Node2D
enum STATUS {IDLE, DIE, ATTACK, HIT, MOVE}	# 状态类型

"""基础属性"""
export var health = 100		# 血量
export var speed = 0		# 移动速度
export var rotation_speed = 0	# 旋转速度

var velocity = Vector2.ZERO	# 当前速度向量
var rotation_dir = 0	# 当前旋转角度
var is_selected = false	# 是否被选中
var status = STATUS.IDLE	# 基础状态

"""基础函数"""
# 状态执行
func do_idle(delta):
	pass
func do_move(delta):
	pass
func do_attack(delta):
	pass
func do_hit(delta):
	pass
func do_die(delta):
	pass

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

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
