"""地面车辆单位类, 继承Unit"""
class_name GroudUnit extends Unit 

# 重写线性力更新
func update_force(delta):
	.update_force(delta)
	# 线性力只保留车辆前后方向
	cur_linear_force = cur_linear_force.rotated(global_rotation)

"""渲染函数"""
func _ready():
	add_to_group("vehicle")
