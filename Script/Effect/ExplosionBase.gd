"""爆炸类"""
class_name ExplosionBase extends Node2D

func _ready():
	$Particles2D.one_shot = true

func _on_Timer_timeout():
	queue_free()
