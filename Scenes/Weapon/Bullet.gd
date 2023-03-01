"""子弹"""
extends Area2D
export var speed = 500		 	# 速度
export var rotation_speed = 1.0	# 转向速度
export var life_time = 500	 # 基础存活时间
export var basic_damage = 5 # 基础伤害
export var aoe_damage = 3	# 范围爆炸伤害
export var cross_level = 1	# 穿击等级, 撞击物体后是否继续前进
export var is_target_locked = false	# 是否锁定目标	

export (PackedScene) var effect_explosion	# 爆炸效果

var target = null	# 攻击的目标
var is_stop = false
var basic_velocity = Vector2.RIGHT
var velocity = Vector2.ZERO
var acceleration_velocity = Vector2.ZERO	# 加速度, 用于平滑移动(导弹跟踪用)

# 执行爆炸
func do_explode():
	if effect_explosion:
		var eff = effect_explosion.instance()
		eff.visible = true
		add_child(eff)

# 降低击穿等级, 为0则等待销毁
func cross_level_decline():
	cross_level -= 1		# 击穿等级降低
	if cross_level <= 0:	# 无法再碰撞, 停止并等待销毁
		is_stop = true
		for child in get_children():
			child.visible = false
		life_time = 30
	do_explode()			# 执行爆炸

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _update_velocity_with_target(target_position:Vector2, delta):
	var line_velocity = (target_position - global_position).normalized() * speed	# 朝向目标的向量, 要用global
	acceleration_velocity = (line_velocity - velocity).normalized() * rotation_speed	# 转向加速度
	velocity += acceleration_velocity * delta	# 更新速度
	velocity = velocity.normalized()			# 限制速率不会超过本身最大速率
	global_rotation = velocity.angle()			# 朝向跟着速度走

func _physics_process(delta):
	if !life_time:
		queue_free()
	life_time -= 1
	# 停止
	if is_stop:
		return
	# 跟踪模式, 根据目标更新速度
	if is_target_locked and target:
		_update_velocity_with_target(target.global_position, delta)
	global_position += velocity * speed * delta

# 撞击到物体
func _on_body_entered(body):
	match body.collision_layer:
		1:	# 单位
			body.do_damage(self)	# 承受伤害
			cross_level_decline()	# 撞击一次降低一次击穿等级
