"""弹药触发器, 发射弹药用"""
extends Node2D

export (PackedScene) var bullet	# 武器弹药
export var gen_number = 1		# 生成数量
export var gen_cd = 5			# 生成CD
export var rotation_offset_range = 0.0 # 随机旋转范围, 正负范围

onready var random = RandomNumberGenerator.new()	# 随机数生成器

var this_position = Vector2.ZERO
var this_rotation = 0
var this_target = null
var cur_bullet_n = 0
var cur_gen_cd = 0

"""
生成弹药信号
bullet_obj 弹药类型
position 全局位置
rotation 全局方向, 会根据随机值偏移
target 攻击目标, 可为空
"""
signal firebullet(bullet_obj, position, rotation, target)

# 获取随机方向, TODO
func get_random_rotation(rotation:float, delta):
	if !rotation_offset_range:
		return rotation
	else:
		var offset = random.randf_range(-1 * rotation_offset_range, rotation_offset_range)
		rotation += offset * delta
		return rotation

# 激活生成弹药
func activate(target=null):
	this_position = global_position
	this_rotation = global_rotation
	this_target = target
	cur_bullet_n = gen_number	# 生成的弹药数量重置

# 生成一次弹药信号
func one_bullet(delta):
	if cur_gen_cd:	# 在CD中冷却
		cur_gen_cd -= 1
	else:			# 发射信号
		emit_signal("firebullet", bullet, 
					this_position, get_random_rotation(this_rotation, delta), 
					this_target)
		cur_gen_cd = gen_cd
		cur_bullet_n -= 1
		
func _ready():
	add_to_group("trigger")

# 有要生成的弹药数量, 则发送信号
func _process(delta):
	if cur_bullet_n:
		one_bullet(delta)
