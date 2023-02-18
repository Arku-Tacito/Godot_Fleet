"""子弹"""
extends Area2D
export var speed = 500		 # 速度
export var life_time = 500	 # 基础存活时间
export var basic_damage = 5 # 基础伤害
export var aoe_damage = 3	# 范围爆炸伤害
export var cross_level = 1	# 穿击等级, 撞击物体后是否继续前进

var target = null
var basic_velocity = Vector2.UP
var velocity = Vector2.ZERO
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !life_time:
		queue_free()
	life_time -= 1
	position += velocity * speed * delta
