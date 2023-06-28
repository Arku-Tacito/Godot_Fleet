"""全局函数区"""
"""要做成单例"""
extends Node

# 根据group_name 获取子节点
func get_children_by_group(cur_node:Node, group_name:String) -> Array:
	var child_list:Array = []
	for child in cur_node.get_children():
		if group_name in child.get_groups():
			child_list.append(child)
		child_list.append_array(get_children_by_group(child, group_name))
	return child_list
