"""机枪平台, 继承武器平台"""
class_name MachinegunModule extends WeaponModule 

# 目标类型判断
func check_target_type(body):
	return (body is Unit) or (body is Module) #or (body is Bullet)

"""渲染函数"""
func _ready():
	add_to_group("machinegun_module")

"""事件函数"""
