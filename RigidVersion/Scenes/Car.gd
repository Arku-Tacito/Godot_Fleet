extends KinematicBody2D

var velocity = Vector2.RIGHT
var speed = 200

func _physics_process(delta):
	velocity += Vector2.DOWN * 0.005
	move_and_slide_with_snap(velocity * speed, Vector2.ZERO, Vector2.UP)

func _exit_tree():
	print_debug("exit_tree")

func _on_Timer_timeout():
	print_debug("queue_free")
	queue_free()
