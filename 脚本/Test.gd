extends Node


var target : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if $Node2D.position != target:
#		#$Node2D.position = $Node2D.position.move_toward(target, delta)	# 修改位置
#		$Node2D.position += (target - $Node2D.position).normalized()
	pass



func _on_move_button_pressed():
	# 参数1: 要进行动画的节点
	# 参数2: 要移动到的位置
	# 参数3: 动画持续时间
	# 参数4: 是否翻转动画
	# 参数5: 是否循环播放动画
	AnimationManager.move_to($Node2D, $Sprite2D.global_position, 2, true, 3)
	#await AnimationManager.move_by($Node2D, Vector2(100, 0), 1, false, 10).finished
	
#	print($Camera2D.get_target_position())
#	$Camera2D.set_notify_transform()
	pass # Replace with function body.

func _on_rotate_button_pressed():
	AnimationManager.rotate_to($Sprite2D, -180, 2, true, 3)
	# AnimationManager.rotate_by($Sprite2D, -45, 1, true, 10)
	
func _on_scale_rotation_button_pressed():
	#AnimationManager.scale_to($Sprite2D, Vector2(0.5, 0.5), 2, true, 10)
	#AnimationManager.scale_by($Sprite2D, Vector2(0.1, 0.1), 1, true, 10)
	AnimationManager.scale_ratio($Sprite2D, Vector2(2, 2), 1, true, 3)
	


func _on_seq_button_pressed():
	# 下面的写法有问题, 因为这些函数会把动画加入到动画队列中播放, 同时 动画序列 也会播放它们
#	var anims = [AnimationManager.move_by($Sprite2D, Vector2(0, -100), 0.5),
#	AnimationManager.move_by($Sprite2D, Vector2(-100, 0), 0.5),
#	AnimationManager.move_by($Sprite2D, Vector2(0, 100), 0.5),
#	AnimationManager.move_by($Sprite2D, Vector2(0, 100), 0.5)]
#	var seq = AnimationManager.sequence(anims)
	
	# 正确的写法
	var anims = [GCAM.MoveBy.new($Sprite2D, Vector2(400, 0), 0.5),
	GCAM.MoveBy.new($Sprite2D, Vector2(0, 400), 0.5),
	GCAM.MoveBy.new($Sprite2D, Vector2(-400, 0), 0.5),
	GCAM.MoveBy.new($Sprite2D, Vector2(0, -400), 0.5)]
	AnimationManager.sequence(anims, false, 3)

