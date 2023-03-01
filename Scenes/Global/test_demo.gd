extends Node2D

# 处理爆炸信号
func _on_explosion_effect(eff_obj, position, rotation):
	var eff = eff_obj.instance()
	eff.global_position = position
	eff.global_rotation = rotation
	add_child(eff)

# 处理发射子弹的信号
func _on_Trigger_firebullet(bullet_obj, position, rotation, target):
	var bu = bullet_obj.instance()
	bu.position = position
	bu.rotation = rotation
	bu.velocity = bu.basic_velocity.rotated(bu.rotation)
	# bu.target = target
	bu.target = $Target		# 测试目标
	bu.connect("explode", self, "_on_explosion_effect")	# 连接爆炸信号
	add_child(bu)

# 连接所有子弹发射信号
func connect_firebullet():
	for child in get_children():
		for group in  child.get_groups():
			if group == "weapon_battery":
				child.get_node("Trigger").connect("firebullet", self, "_on_Trigger_firebullet")

func _ready():
	connect_firebullet()
