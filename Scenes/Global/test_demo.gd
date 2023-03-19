extends Node2D

# 处理爆炸信号
func _on_explosion_effect(eff_obj, position, rotation):
	var eff = eff_obj.instance()
	eff.global_position = position
	eff.global_rotation = rotation
	add_child(eff)

# 处理发射子弹的信号
func _on_Trigger_firebullet(bullet_obj, position, rotation, target, owner):
	var bu = bullet_obj.instance()
	bu.do_ready(position, rotation, target, owner)
	bu.connect("explode", self, "_on_explosion_effect")	# 连接爆炸信号
	add_child(bu)
	
# 处理单位
func deal_with_unit(unit):
	unit.connect("explode", self, "_on_explosion_effect")	# 连接爆炸信号
	if "weapon_battery" in unit.get_groups():
		unit.connect("firebullet", self, "_on_Trigger_firebullet")	# 连接所有子弹发射信号
	for child in unit.get_children():
		if "unit" in child.get_groups():
			deal_with_unit(child)

# 子节点初始化时连接信号
func children_connect_signal():
	for child in get_children():
		if "unit" in  child.get_groups():
			deal_with_unit(child)

func _ready():
	children_connect_signal()
