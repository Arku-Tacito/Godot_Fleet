"""全局变量区"""
"""要做成单例"""
extends Node

"""碰撞层定义, 要与项目设置的保持一致"""
const LAYER_SHIP:int = 1
const LAYER_BULLET:int = 2
const LAYER_CRAFT:int = 4
const LAYER_BUILDING:int = 8
const LAYER_MODULE:int = 16
const LAYER_OBJECT:int = 32

const LAYER_MISSILE:int = LAYER_BULLET | LAYER_CRAFT	# 导弹

"""阵营定义"""
const FACTION_UNKNOWN:int = -1
