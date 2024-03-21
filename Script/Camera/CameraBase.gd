"""相机基类"""
class_name CameraBase extends Camera2D

"""属性"""
# 外部属性
@export var zoom_speed:float = 0.1			# 缩放速度
@export var translate_speed:float = 0.1		# 平移速度
@export var zoom_lerp:int = 8				# 缩放平滑度

# 相机缩放限制
@export var zoom_min:float = 2
@export var zoom_max:float = 10

var cur_zoom:Vector2 = zoom					# 当前的缩放

# 平移相关
var is_drag:bool = false						# 是否拖动状态
var drag_start_position:Vector2 = Vector2.ZERO	# 拖动时的鼠标初始位置
var drag_start_cam_positon:Vector2 = position	# 拖动前相机的初始位置

"""接口函数"""
# 初始化相机主要属性
func init(zoom_x:float, zoom_y:float, offset_x:float, offset_y:float, new_anchor_mode):
	set_anchor_mode(new_anchor_mode)
	set_zoom(Vector2(zoom_x, zoom_y))
	set_offset(Vector2(offset_x, offset_y))

# 设置相机缩放限制
func set_zoom_limit(new_zoom_min:float, new_zoom_max:float):
	zoom_min = new_zoom_min
	zoom_max = new_zoom_max
	
"""辅助函数"""
# 缩放
func do_zoom(is_zoom_up:bool):
	if is_zoom_up:	# 镜头缩小
		if zoom.x < zoom_max:
			cur_zoom.x += zoom_speed
			cur_zoom.y += zoom_speed
		if cur_zoom.x > zoom_max:
			cur_zoom.x = zoom_max
		if cur_zoom.y > zoom_max:
			cur_zoom.y = zoom_max
	else:	# 镜头放大
		if zoom.x > zoom_min:
			cur_zoom.x -= zoom_speed
			cur_zoom.y -= zoom_speed
		if cur_zoom.x < zoom_min:
			cur_zoom.x = zoom_min
		if cur_zoom.y < zoom_min:
			cur_zoom.y = zoom_min
	# 不让相机平移
	is_drag = false
	
# 平移
## 拖动开始与停止
func do_drag(is_pressed:bool, start_position:Vector2):
	if is_pressed:
		is_drag = true
		drag_start_position = start_position
		drag_start_cam_positon = position
	else:
		is_drag = false
		drag_start_position = Vector2.ZERO

# 是否移动到边界
func is_hit_boundary(position:Vector2):
	if position.x > limit_right or position.x < limit_left:
		return true
	if position.y > limit_bottom or position.y < limit_top:
		return true
	return false

## 更新拖动位置
func update_dragging(new_position:Vector2):
	if not is_drag:	# 非拖动状态不更新
		return
	if is_hit_boundary(new_position):	# 触及边界
		return
	# 根据偏移调整相机位置
	var offset = new_position - drag_start_position
	position = drag_start_cam_positon - offset * zoom.x	# 偏移幅度与缩放相关

"""渲染函数"""
func _ready():
	set_anchor_mode(Camera2D.ANCHOR_MODE_DRAG_CENTER)

# 输入事件
func _input(event):
	if not current:	# 不是当前的相机不操作
		return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:	# 滚轮缩放
				do_zoom(event.button_index == MOUSE_BUTTON_WHEEL_DOWN)	# 往上拉放大
			MOUSE_BUTTON_MIDDLE:						# 中键拖动
				do_drag(event.is_pressed(), event.position)
	# 更新拖动的位置
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		update_dragging(event.position)

func _process(delta):
	# 缩放平滑刷新
	zoom = lerp(zoom, cur_zoom, zoom_lerp * delta)
