extends Node2D

var origin_transform

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_transform = $Sprite2D.transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer/ColorRect2/PositionLabel/Label.text = str($Sprite2D.position)
	$CanvasLayer/ColorRect2/ScaleLabel/Label.text = str($Sprite2D.scale)
	$CanvasLayer/ColorRect2/RotationLabel/Label.text = str(rad_to_deg($Sprite2D.rotation))
	$CanvasLayer/ColorRect2/SkewLabel/Label.text = str(rad_to_deg($Sprite2D.skew))

func get_duration()->float:
	var duration = float($CanvasLayer/ColorRect/DurationLabel/TextEdit.text)
	print("时间:", duration)
	return duration
	
func get_loop_count()->int:
	var count = int($CanvasLayer/ColorRect/LoopCountLabel/TextEdit.text)
	print("循环次数:", count)
	return count
	
func get_flip()->bool:
	var flip = $CanvasLayer/ColorRect/FlipButton.button_pressed
	print("翻转:", flip)
	return flip
	
func _on_move_to_pressed():
	# 移动到指定位置
	AnimationManager.move_to($Sprite2D, $MoveToTarget.position, get_duration(), get_flip(), get_loop_count())


func _on_move_by_pressed():
	# 移动一个变化量
	AnimationManager.move_by($Sprite2D, Vector2(200, 200), get_duration(), get_flip(), get_loop_count())


func _on_rotate_to_pressed():
	# 旋转到指定角度
	AnimationManager.rotate_to($Sprite2D, 90, get_duration(), get_flip(), get_loop_count())


func _on_rotate_by_pressed():
	# 旋转变化指定角度
	AnimationManager.rotate_by($Sprite2D, -45, get_duration(), get_flip(), get_loop_count())


func _on_scale_to_pressed():
	# 缩放到指定大小
	AnimationManager.scale_to($Sprite2D, Vector2(0.5, 0.5), get_duration(), get_flip(), get_loop_count())


func _on_scale_by_pressed():
	# 缩放一个变化量
	AnimationManager.scale_by($Sprite2D, Vector2(0.5, 0.5), get_duration(), get_flip(), get_loop_count())


func _on_scale_ratio_pressed():
	# 按比例缩放
	AnimationManager.scale_ratio($Sprite2D, Vector2(2, 2), get_duration(), get_flip(), get_loop_count())


func _on_sequence_pressed():
	# 依次播放动画
	var anims = [GCAM.MoveBy.new($Sprite2D, Vector2(400, 0), 0.5),
	GCAM.MoveBy.new($Sprite2D, Vector2(0, 400), 0.5),
	GCAM.MoveBy.new($Sprite2D, Vector2(-400, 0), 0.5),
	GCAM.MoveBy.new($Sprite2D, Vector2(0, -400), 0.5)]
	AnimationManager.sequence(anims, get_flip(), get_loop_count())


func _on_skew_to_pressed():
	# 倾斜到指定角度
	AnimationManager.skew_to($Sprite2D, 90, get_duration(), get_flip(), get_loop_count())


func _on_reset_button_pressed():
	$Sprite2D.transform = origin_transform
	AnimationManager.clear_anims()

func _on_skey_by_pressed():
	# 倾斜变化量角度
	AnimationManager.skew_by($Sprite2D, -15, get_duration(), get_flip(), get_loop_count())

# 自定义动画, 通过改变动画计时器来实现简谐运动
class SinMove extends GCAM.MoveTo:
	# time 是用来对节点属性进行插值的参数, 取值为[0, duration]
	# 对时间进行变换
	# 返回值影响节点的属性, 返回0, 表示初值
	# 返回 1 表示目标值
	# 返回 -1,表示目标的相反值, 其他值就是倍数
	# 比如 x 坐标, 当前值 = (x1 - x0) * update_timer()
	func update_timer(time:float):
		return sin(3 * time)
	
func _on_test_pressed():
	# 添加一个自定义的简谐运动动画对象
	AnimationManager.add_anim(SinMove.new($Sprite2D, $MoveToTarget.position, 100))


# 物理忘光了
class SimplePendulum extends GCAM.MoveTo:
	const g:float = 500	# 重力加速度
	var L:float		# 绳长
	# 构造函数, 计算绳子的长度
	func _init(node:Node2D, target:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, target, duration, is_flip, loop_count)
		
		L = target.distance_to(node.position)
		
	# 根据单摆公式计算时间(实际上这里的结果是角度)
	func update_timer(time:float):
		var w = sqrt(g/L)
		return sin(w * time)	# 将
		
	# 根据update_timer计算出来的时间(角度)更改节点的位置
	func change(time:float):
		# orgin 就是构造函数中传入的这个节点的初始位置, 这里 + (0, -400) 来当作单摆的圆心
		# 中间那个Vector2就是当前的位移
		node.position = origin + Vector2(-L * sin(time), L * cos(time)) + Vector2(0, -400)

func _on_test_2_pressed():
	# 添加一个自定义的单摆运动动画对象
	AnimationManager.add_anim(SimplePendulum.new($Sprite2D, $MoveToTarget.position, 100))
