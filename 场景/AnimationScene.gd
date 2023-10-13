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


func _on_skey_by_pressed():
	# 倾斜变化量角度
	AnimationManager.skew_by($Sprite2D, -15, get_duration(), get_flip(), get_loop_count())


func _on_test_pressed():
	$Sprite2D.set("position", Vector2(500, 500))
