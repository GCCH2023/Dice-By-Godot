class_name GCAM
extends Node

#用于实现简单动画的脚本

var test = 100

# 定义动画的基本属性
class GCAnimation:
	# 形成链表的属性
	var next : GCAnimation	# 下一个动画
	var prev : GCAnimation 	# 上一个动画
	
	# 藐视动画的属性, 在动画过程中不会修改
	var node : Node2D		# 目标节点
	var duration : float	# 持续时间
	var is_flip : bool		# 是否翻转动画
	var loop_count : int 		# 循环次数, 正反算一次
	var is_flipping : bool	# 是否正在翻转
	var is_finished : bool	# 动画是否播放完毕, 播放完毕将被删除
	
	# 信号
	signal finished		# 动画结束时调用
	
	# 动画变量, 在动画过程中会修改
	var timer : float 		# 动画计时
	var iterator : int		# 当前动画播放次数
	
	func _init(node:Node2D, duration:float=1, is_flip:bool=false, loop_count:int=1):
		self.next = null
		self.prev = null

		self.node = node
		self.duration = duration
		self.is_flip = is_flip
		self.loop_count = loop_count
		self.is_flipping = false
		self.is_finished = false

		self.timer = 0
		self.iterator = 0
		
	# 重置动画计时器
	func reset():
		timer = 0
		is_finished = false
		
	# 修改节点的属性
	# time 的含义视具体情况而定
	func change(time:float):
		pass
		
	func on_finished():
		is_finished = true
		emit_signal("finished")
		
	# 处理动画细节
	func process(delta:float):
		change(delta)
	
	# 播放完一次动画之后调用, 接下来将开始下一轮循环或播放翻转动画
	func before_next():
		pass
		
	# 更新动画计时器
	func update_timer(delta:float):
		if !is_flipping:
			timer += delta
		else:
			timer -= delta
		
	# delta 是 _process 的参数
	func update(delta:float):
		update_timer(delta)
		process(delta)
		
		# 动画完成后重置计时器
		if timer >= duration:
			if is_flip:		# 需要翻转, 当前是正动画的话
				is_flipping = true		# 设置翻转标志, 接下来播放翻转动画
				timer = duration
			elif iterator + 1 < loop_count:	# 不需要翻转, 那么判断是否循环
				iterator += 1
				reset()
			else:	# 结束动画
				on_finished()
				return
			before_next()
		elif timer <= 0:		# 反动画完毕, 不需要循环播放就结束动画
			if iterator + 1 >= loop_count:
				on_finished()
				return
			else:		# 循环下一次
				iterator += 1
				is_flipping = false
				reset()
			before_next()

# 目标值动画
# change 中 time 是从动画开始经过的时间与duration的比值, 属于[0, 1]
class TargetAnimation extends GCAnimation:
	var origin		# 原来的属性值
	var target		# 目标属性值

	func _init(node:Node2D, origin, target, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super(node, duration, is_flip, loop_count)
		
		self.origin = origin
		self.target = target

	# 处理动画细节
	func process(delta:float):
		# 计算插值因子（0到1之间）
		var t = timer / duration
		t = clamp(t, 0, 1) # 限制在0到1之间
		change(t)

# 变化量动画
class DeltaAnimation extends GCAnimation:
	var origin		# 原来的属性值
	var delta		# 变化量

	func _init(node:Node2D, origin, delta, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super(node, duration, is_flip, loop_count)
		
		self.origin = origin
		self.delta = delta

# 动画链表
var head : GCAnimation = null
var tail : GCAnimation = null

func add_anim(anim:GCAnimation):
	# 尾插法
	if tail:
		tail.next = anim
	anim.next = null
	anim.prev = tail
	if tail == null:
		head = anim
	tail = anim
	
func remove_anim(anim:GCAnimation):
	var next = anim.next
	var prev = anim.prev
	if next:
		next.prev = prev
	if prev:
		prev.next = next
	anim.next = null
	anim.prev = null
	if anim == head:
		head = next
	if anim == tail:
		tail = prev

# 移动节点的动画
class MoveTo extends TargetAnimation:

	func _init(node:Node2D, target:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.position, target, duration, is_flip, loop_count)
		
	func change(time:float):
		# 使用插值因子来计算角色当前位置, 更新角色位置
		node.position = lerp(origin, target, time)
		
		
# 移动节点的动画
class MoveBy extends DeltaAnimation:

	func _init(node:Node2D, delta:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.position, delta, duration, is_flip, loop_count)

	func change(time:float):
		if is_flipping:
			node.position = node.position - delta * time
		else:
			node.position = node.position + delta * time
	
# 旋转节点到目标角度的动画
class RotateTo extends TargetAnimation:
	# !!! target 是角度
	func _init(node:Node2D, target:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.rotation, deg_to_rad(target), duration, is_flip, loop_count)
		
	func change(time:float):
		print(origin, target, time)
		node.rotation = lerp(origin, target, time)
		
# 旋转节点的一个bug, 还挺有趣的, 保留下来
class RotateToBug1 extends RotateTo:
	
	func change(time:float):
		node.rotate(lerp(origin, target, time))
		
# 旋转节点一个变化量的动画
class RotateBy extends DeltaAnimation:

	func _init(node:Node2D, degree:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.rotation, deg_to_rad(degree), duration, is_flip, loop_count)

	func change(time:float):
		if is_flipping:
			node.rotation -= delta * time
		else:
			node.rotation += delta * time
	
# 缩放节点到目标值的动画
class ScaleTo extends  TargetAnimation:

	func _init(node:Node2D, target:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.scale, target, duration, is_flip, loop_count)
		
	func change(time:float):
		node.scale = lerp(origin, target, time)
	
# 按变化量缩放节点
# 比如初始缩放为(1.5, 1.5), delta为(-0.5, -0.5), 则第1次播放动画, 缩放变为(1.0, 1.0)
# 再播放一次动画缩放变为(0, 0), 当节点的缩放值有一个分量小于等于0则, 动画结束
class ScaleBy extends  DeltaAnimation:
	func _init(node:Node2D, delta:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.scale, delta, duration, is_flip, loop_count)
		
	func change(time:float):
		if is_flipping:
			node.scale -= delta * time
		else:
			node.scale += delta * time
		if node.scale.x <= 0 || node.scale.y <= 0:
			on_finished()
			
# 按比例缩放节点
# 比如初始缩放为(1.5, 1.5), delta为(0.5, 0.5), 则第1次播放动画, 缩放变为(0.75, 0.75)
# 再播放一次动画缩放变为(0.375, 0375)
# !!!target 被当作 变化量来使用
class ScaleRatio extends  TargetAnimation:
	var end : Vector2
	
	func _init(node:Node2D, delta:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.scale, delta, duration, is_flip, loop_count)
		self.end = self.origin * delta
		
	func change(time:float):
		node.scale = lerp(origin, end, time)
			
	func before_next():
		if !is_flipping:
			origin = node.scale
			end = origin * target

# 倾斜节点一个变化量的动画
class SkewBy extends DeltaAnimation:

	func _init(node:Node2D, degree:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.skew, deg_to_rad(degree), duration, is_flip, loop_count)

	func change(time:float):
		if is_flipping:
			node.skew -= delta * time
		else:
			node.skew += delta * time
	
# 倾斜节点到目标值的动画
class SkewTo extends TargetAnimation:

	func _init(node:Node2D, target:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
		super._init(node, node.skew, deg_to_rad(target), duration, is_flip, loop_count)
		
	func change(time:float):
		node.skew = lerp(origin, target, time)

		
# 序列动画, 可以容纳多个动画, 这些动画依次播放
class SequenceAnimation extends GCAnimation:
	var anims : Array
	var current : GCAnimation
	var index : int
	
	func _init(anims:Array, is_flip:bool=false, loop_count:int=1):
		super._init(null, 0, is_flip, loop_count)
		self.anims = anims
		self.index = 0
		next_animation()
		
	func next_animation():
		current = anims[index]
		current.reset()
		#current.finished.connect(on_anim_finished)
		
	# delta 是 _process 的参数
	func update(delta:float):
		current.update(delta)
		if current.is_finished:
			if index + 1 >= anims.size():
				if loop_count <= 1:
					on_finished()
				else:
					loop_count -= 1
					index = 0
					next_animation()
			else:
				index += 1
				next_animation()
	
# 将节点node平移用duration指定的时间到指定位置target
func move_to(node:Node2D, target:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = MoveTo.new(node, target, duration, is_flip, loop_count)
	add_anim(anim)
	return anim

# 增量方式平移节点
func move_by(node:Node2D, vector:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = MoveBy.new(node, vector, duration, is_flip, loop_count)
	add_anim(anim)
	return anim
	
# 将节点node从当前角度旋转到指定角度
# degreee 是正值则顺时针旋转, 负值则逆时针旋转
func rotate_to(node:Node2D, degreee:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = RotateTo.new(node, degreee, duration, is_flip, loop_count)
	add_anim(anim)
	return anim
	
# 将节点node从当前角度旋转到指定角度
func rotate_to_bug1(node:Node2D, degreee:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = RotateToBug1.new(node, degreee, duration, is_flip, loop_count)
	add_anim(anim)
	return anim

# 增量方式旋转节点
# degreee 是正值则顺时针旋转, 负值则逆时针旋转
func rotate_by(node:Node2D, degreee:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = RotateBy.new(node, degreee, duration, is_flip, loop_count)
	add_anim(anim)
	return anim

# 将节点node从当前角度倾斜到指定角度
# degreee 是正值则顺时针倾斜, 负值则逆时针倾斜
func skew_to(node:Node2D, degreee:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = SkewTo.new(node, degreee, duration, is_flip, loop_count)
	add_anim(anim)
	return anim

# 增量方式倾斜节点
# degreee 是正值则顺时针倾斜, 负值则逆时针倾斜
func skew_by(node:Node2D, degreee:float, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = SkewBy.new(node, degreee, duration, is_flip, loop_count)
	add_anim(anim)
	return anim
	
func scale_to(node:Node2D, target:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = ScaleTo.new(node, target, duration, is_flip, loop_count)
	add_anim(anim)
	return anim

# 按比例缩放节点
# 比如delta为(0.5, 0.5), 则第1次播放动画, 节点变为原来的一半, 第
# 2次播放节点变为一半的一半, 即1/4
func scale_by(node:Node2D, vector:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = ScaleBy.new(node, vector, duration, is_flip, loop_count)
	add_anim(anim)
	return anim
	
# 按比例缩放节点
# 比如初始缩放为(1.5, 1.5), delta为(0.5, 0.5), 则第1次播放动画, 缩放变为(0.75, 0.75)
# 再播放一次动画缩放变为(0.375, 0375), 当节点的缩放值有一个分量小于等于0则, 动画结束
func scale_ratio(node:Node2D, ratio:Vector2, duration:float=1, is_flip:bool=false, loop_count:int=1):
	var anim = ScaleRatio.new(node, ratio, duration, is_flip, loop_count)
	add_anim(anim)
	return anim
	
# 创建一个动画序列
# 动画序列可以包含并同步播放多个动画
func sequence(anims:Array, is_flip:bool=false, loop_count:int=1):
	if anims.is_empty():
		return
	var anim = SequenceAnimation.new(anims, is_flip, loop_count)
	add_anim(anim)
	return anim
	
	
func _process(delta):
	var anim:GCAnimation = head
	while anim != null:
		var next = anim.next
		anim.update(delta)
		if anim.is_finished:
			remove_anim(anim)
		anim = next
				



# 角色视角切换问题
# 每个角色下面需要有一个相机, 场景下面有一个主相机,
# 角色移动跟随使用角色下面的相机, 角色切换使用主相机
# 第一次时, 当需要切换到第一个角色时, 将主相机平移到该角色的位置, 然后切换到该该角色的相机
# 此后, 每到切换下一个角色时, 先将主相机的位置设为当前角色的位置, 并切换到主相机
# 接着, 主相机平移到下一个角色的位置, 切换到下一个角色的相机
var main_camera : Camera2D
var main_camera_node : Node2D
signal camera_switched

func set_main_camera(main:Camera2D):
	main_camera = main
	if main:
		main_camera_node = main.get_parent()

# 从一个角色的相机切换到下一个角色的相机
# cur_camera 如果为空, 则从主相机的当前位置切换
# next_camera 不能为空
func switch_camera(cur_camera:Camera2D, next_camera:Camera2D, duration:float=1):
	if cur_camera != null:
		main_camera.global_position = cur_camera.get_parent().global_position
		main_camera.make_current()
	# 平移动画
	var target = next_camera.get_parent().global_position
	target = main_camera_node.to_local(target)
	var anim = move_to(main_camera, target, duration)
	anim.finished.connect(func(): emit_signal("camera_switched"))
	await anim.finished
	next_camera.make_current()











