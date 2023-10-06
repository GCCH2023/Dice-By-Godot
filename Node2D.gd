extends Node2D

var current : Node2D

func on_switched():
	# 相机切换完毕后, 此时角色相机成为当前相机, 让角色移动一段距离
	await  AnimationManager.move_by(current, Vector2i(400, 0), 1).finished
	print("switched")
	var next = $Role2 if current == $Role1 else $Role1
	AnimationManager.switch_camera(current.get_node("角色相机"), next.get_node("角色相机"))
	current = next

# Called when the node enters the scene tree for the first time.
func _ready():
	# 设置主相机
	AnimationManager.set_main_camera($Node2D/主相机)
	# 连接相机切换完毕的信号
	AnimationManager.camera_switched.connect(on_switched)
	
	current = $Role1
	# 第一个参数为null表示从主相机切换到第一个角色的相机
	AnimationManager.switch_camera(null, $Role1/角色相机)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
