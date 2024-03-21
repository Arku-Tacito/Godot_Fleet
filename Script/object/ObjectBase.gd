"""物体基类, 实现基础的物理行为"""
class_name ObjectBase extends CharacterBody2D

"""外部成员"""
@export_category("physical")
@export var rotation_speed:float = 0		# 旋转速度
@export var max_speed:float = 100			# 最大线速度

@export var max_force: float = 100			# 最大推力
@export var weight: float = 10				# 重量

@export_category("movement_strategy")
@export var is_stop: bool = false			# 是否停止
@export var is_auto: bool = true			# 是否自动行为
@export var is_selected: bool = false		# 是否被选择
@export var set_gravity: bool = true		# 设置重力加速度

"""内部成员"""
var dst_location: Vector2	# 目标地点
var max_acc_speed: float = 0
var cur_speed: float = 0
var linear_acc: Vector2 = Vector2.ZERO

"""函数"""
func cal_linear_acc(cur_pos: Vector2, dst_pos: Vector2, cur_velocity: Vector2,
		max_speed: float, max_acc_speed: float, delta: float):

	# 计算期望速度
	var expected_vel: Vector2 = (dst_pos - cur_pos) / delta
	if expected_vel.length() > max_speed:
		expected_vel = expected_vel.normalized() * max_speed

	# 计算期望加速度
	var expected_acc: Vector2 = expected_vel - cur_velocity
	if set_gravity:							# 考虑重力加速度
		expected_acc -= Vector2(0, 0.98)
	if expected_acc.length() > max_acc_speed:
		expected_acc = expected_acc.normalized() * max_acc_speed
	
	return expected_acc
	
func cal_velocity(cur_pos: Vector2, dst_pos: Vector2, cur_velocity: Vector2,
		max_speed: float, max_acc_speed: float):
	# 起步
	var target_vec:Vector2 = dst_pos - cur_pos
	if not cur_speed:
		cur_speed += max_acc_speed
		return target_vec.normalized() * cur_speed
	# 判断是该减速还是加速
	if target_vec.dot(cur_velocity) >= 0:
		cur_speed = min(cur_speed + max_acc_speed, max_speed)
	else:
		cur_speed = max(cur_speed - max_acc_speed, 0)
	# 速度转向
	var angle = cur_velocity.angle_to(target_vec) * rotation_speed
	var new_velocity = cur_velocity.normalized().rotated(angle) * cur_speed
	print_debug(angle)
	print_debug(new_velocity)
	return new_velocity


func update_velocity():
	velocity = velocity + linear_acc
	if set_gravity:
		velocity += Vector2(0, 0.98)

func update_velocity_by_input():
	var vel_nor = Vector2.ZERO
	if Input.is_action_pressed("Left"):
		vel_nor += Vector2.LEFT
	if Input.is_action_pressed("Right"):
		vel_nor += Vector2.RIGHT
	if Input.is_action_pressed("MoveUp"):
		vel_nor += Vector2.UP
	if Input.is_action_pressed("MoveDown"):
		vel_nor += Vector2.DOWN
	velocity = vel_nor * max_speed

func update_acc_length():
	max_acc_speed = max_force / weight

func update_dst_location(dst_loc:Vector2):
	dst_location = dst_loc	

""""""
# Called when the node enters the scene tree for the first time.
func _ready():
	dst_location = global_position
	update_acc_length()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_selected:
		update_velocity_by_input()
	elif is_auto:
		#linear_acc = cal_linear_acc(global_position, dst_location, velocity, max_speed, max_acc_speed, delta)
		#update_velocity()
		velocity = cal_velocity(global_position, dst_location, velocity, max_speed, max_acc_speed)
	if not is_stop:
		move_and_slide()
