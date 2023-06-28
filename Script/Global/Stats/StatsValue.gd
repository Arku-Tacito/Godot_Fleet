"""单位属性值, 需要做成单例"""

class DefaultStats:
	var health:float = 100	# 血量
	var level:int 	= 1		# 等级

class ShipStats extends DefaultStats:
	func _init():
		health = 120
