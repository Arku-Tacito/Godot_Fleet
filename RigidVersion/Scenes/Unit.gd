extends RigidBody2D

export var force:float = 400
var max_speed:float = 80

var stop_distance = 10
var move_pos = Vector2.ZERO

func _ready():
	move_pos = global_position
	add_to_group("unit")
	#add_central_force(Vector2(0, -100 * gravity_scale))

func do_move(delta):
	# 停止施加线性力
	var direction_dst:Vector2 = move_pos - global_position
	if direction_dst.length() < max(linear_velocity.length(), stop_distance):
		#if direction_dst.dot(linear_velocity) > 0:
		return
	# 计算线性力方向
	var move_dir:Vector2 = direction_dst.normalized()
	if linear_velocity.length() > max_speed:
		move_dir += -1.5 * linear_velocity.normalized()
	var apply_force:Vector2 = move_dir.normalized() * force * delta
	apply_central_impulse(apply_force)
#	for engine in get_tree().get_nodes_in_group("engine"):
#		engine.call_flame(apply_force + apply_force.normalized() * linear_damp * 500 + Vector2.UP * 100)
	
func balace_uprignt(delta):
	# 保持水平平衡
	var torque_force = 100
	if rotation_degrees > 0:
		torque_force *= -1
	if abs(rotation_degrees) > 1:
		apply_torque_impulse(torque_force * delta)

func _physics_process(delta):
	do_move(delta)
	balace_uprignt(delta)
		
