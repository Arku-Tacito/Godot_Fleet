"""飞行单位类, 继承Unit"""
class_name AirUnit extends Unit 

var anti_gravity_force:Vector2 = Vector2.ZERO	# 反重力

# 反重力
func apply_anti_gravity_force():
	anti_gravity_force = Vector2(0, mass * 98 * gravity_scale) * -1
	add_central_force(anti_gravity_force)
	
# 重置重力影响
func reset_anti_gravity_force():
	anti_gravity_force = Vector2.ZERO
	add_central_force(anti_gravity_force)

"""渲染函数"""
func _ready():
	add_to_group("aircraft")
	set_linear_damp(0.5)		# 默认设置摩擦力
	apply_anti_gravity_force()	# 默认飞起来不会被重力影响
