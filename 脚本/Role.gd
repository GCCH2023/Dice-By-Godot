extends CharacterBody2D

@export var SPEED : int = 100
@export var RoleName : String
@export var IsPlayer : bool = false

signal move_end(role : Node2D)

const CELL = 32
const LEFT : int = 0x10000
const UP : int = 0x20000
const RIGHT : int = 0x30000
const DOWN : int = 0x40000

var target = Vector2.ZERO
var queue = []
var is_moving = false
var direction = Vector2i.ZERO
var is_end_moving = true	# 用于标记连续的多个移动指令的结束

# 构成闭合链表
var next : CharacterBody2D
var prev : CharacterBody2D

func move_left(cell = 1):
	is_moving = true
	target = position + Vector2(-CELL * cell, 0)
	$Animation.play("向左")
	direction = Vector2i.DOWN
	
func move_right(cell = 1):
	is_moving = true
	target = position + Vector2(CELL * cell, 0)
	$Animation.play("向右")
	direction = Vector2i.RIGHT
	
func move_up(cell = 1):
	is_moving = true
	target = position + Vector2(0, -CELL * cell)
	$Animation.play("向上")
	direction = Vector2i.UP
	
func move_down(cell = 1):
	is_moving = true
	target = position + Vector2(0, CELL * cell)
	$Animation.play("向下")
	direction = Vector2i.DOWN
	
func add_move(op : int, step : int):
	queue.append(op | step)
	
func add_move_by_vec(vec : Vector2i, step : int = 1):
	print("添加移动向量: ", vec, " * ", step)
	if vec == Vector2i.LEFT:
		add_move(LEFT, step)
	elif vec == Vector2i.RIGHT:
		add_move(RIGHT, step)
	elif vec == Vector2i.UP:
		add_move(UP, step)
	elif vec == Vector2i.DOWN:
		add_move(DOWN, step)
		
# 执行移动
func move():
	var instruction = queue[0]
	var op = instruction & 0xFFFF0000
	var step = instruction & 0xFFFF
	queue.pop_front()
	is_end_moving = false
	if (op == LEFT):
		move_left(step)
	elif (op == UP):
		move_up(step)
	elif (op == RIGHT):
		move_right(step)
	elif (op == DOWN):
		move_down(step)
	
#执行完一次移动后
func move_finished():
	if queue.is_empty():
		$Animation.stop()
		is_moving = false
		emit_signal("move_end", self)
		return
	move()
	
func _ready():
#	add_move(RIGHT, 5)
#	add_move(DOWN, 5)
#	add_move(LEFT, 2)
#	add_move(UP, 2)
	pass

func _process(delta):
	if is_moving:
		if position == target:
			if is_end_moving == false:
				is_end_moving = true
				move_finished()	# 移动结束
		else:
			position = position.move_toward(target, delta * SPEED)	# 修改位置
	elif !queue.is_empty():
		move()
