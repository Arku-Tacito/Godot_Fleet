"""阵营相关接口"""
"""要做成单例"""
extends Node

"""外交系统加入则扩充"""
# 判断是否为友方
# 目前用最简单的判断
func is_friendly(from_faction:int, to_faction:int) -> bool:
	return from_faction == to_faction
