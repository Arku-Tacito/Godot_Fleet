"""模块基类"""
class_name ModuleBase extends StaticBody2D

"""外部属性"""
# 基础
@export var health:float = 200				# 血量

# 控制
@export var faction:int = GlobalValue.FACTION_UNKNOWN	# 阵营
@export var is_selected:bool = false			# 是否被选中

"""内部属性"""
var myowner:UnitBase = null					# 所属

# 这里要给一个固定的速度, 用于计算瞄准
const velocity:Vector2 = Vector2.ZERO		
const speed:float = 0.0

# 效果
@export (PackedScene) var effect_explosion	# 爆炸效果
signal explode(eff_obj, position, rotation)	# 爆炸信号

"""接口函数"""
# 设置阵营
func set_faction(new_faction:int):
	faction = new_faction

# 承受伤害
func take_damage(from:UnitBase, hit_point:float):
	health -= hit_point
	if health <= 0:
		health = 0
		process_die()
	# TODO: 增加经验
	
"""状态执行函数"""
# 处理承受伤害, 这里不是计算伤害的地方, 主要用于播放动画
func process_hit():
	pass

# 处理死亡
func process_die():
	if effect_explosion:	# 爆炸效果
		emit_signal("explode", effect_explosion, global_position, global_rotation)
	queue_free()

"""渲染函数"""
func _ready():
	add_to_group("module_base")	# 将自己的节点列为模块节点组
	# 阵营所属
	if is_instance_valid(myowner):
		faction = myowner.faction
