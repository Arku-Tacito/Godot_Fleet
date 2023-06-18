extends Sprite

func _process(delta):
	if Input.is_action_pressed("MoveUp"):
		position.y -= 1
	if Input.is_action_pressed("MoveDown"):
		position.y += 1
	if Input.is_action_pressed("Left"):
		position.x -= 1
	if Input.is_action_pressed("Right"):
		position.x += 1
