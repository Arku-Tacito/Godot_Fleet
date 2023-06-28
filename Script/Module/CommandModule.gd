"""指挥模块"""
class_name CommandModule extends Module

"""运动属性"""
export var attack_range:float = 300		# 攻击距离, 用于判定移动位置

"""对战属性"""
var target_manager:TargetManager = TargetManager.new()	# 攻击目标管理

"""信号"""

"""辅助函数"""
func check_target_type(body) -> bool:
	return (body is Unit) #or (body is Module)

func add_target(body):
	target_manager.add_target(body, true, false)	# 放在下一个位置

func remove_target(body):
	if not check_target_type(body):
		return
	target_manager.remove_target(body)

"""移动函数"""

"""状态更新函数"""
# 根据目标更新移动位置
func update_move_pos():
	target_manager.update_target()
	var target = target_manager.attack_target
	if not is_instance_valid(myowner):
		return
	if is_instance_valid(target):
		# TODO: 移动位置偏移
		myowner.move_pos = move_inf.get_move_pos(target.global_position, myowner.global_position, attack_range)
	else:
		# 没有目标, 保持自己的位置
		myowner.move_pos = myowner.global_position

"""渲染函数"""
# 被销毁时, 生成爆炸和残骸效果
func _exit_tree():
	emit_signal("sig_explode", null, global_position, global_rotation)

func _ready():
	add_to_group("command_module")

func _physics_process(delta):
	update_status()
	update_move_pos()
