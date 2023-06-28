"""战场管理器"""
class_name CombatManager extends Node2D

# 处理发射子弹的信号
func _on_Trigger_firebullet(bullet_obj, position, rotation, target, owner):
	var bu = bullet_obj.instance()
	bu.do_ready(position, rotation, target, owner)
	bu.connect("explode", self, "_on_explosion_effect")	# 连接爆炸信号
	add_child(bu)

# 处理模块
func _deal_with_module(module):
	if "weapon_module" in module.get_groups():
		module.connect("firebullet", self, "_on_Trigger_firebullet")	# 连接所有子弹发射信号

func _ready():
	for module in get_tree().get_nodes_in_group("module"):
		_deal_with_module(module)

func _process(delta):
	pass
