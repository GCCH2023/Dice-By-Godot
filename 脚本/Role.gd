extends CharacterBody2D

@export var SPEED : int = 100

const CELL = 32
const LEFT : int = 0x10000
const UP : int = 0x20000
const RIGHT : int = 0x30000
const DOWN : int = 0x40000

var target = Vector2.ZERO
var queue = []
var is_moving = false

func move_left(cell = 1):
	target = position + Vector2(-CELL * cell, 0)
	$Animation.play("向左")
	
func move_right(cell = 1):
	target = position + Vector2(CELL * cell, 0)
	$Animation.play("向右")
	
func move_up(cell = 1):
	target = position + Vector2(0, -CELL * cell)
	$Animation.play("向上")
	
func move_down(cell = 1):
	target = position + Vector2(0, CELL * cell)
	$Animation.play("向下")
	
func add_move(op : int, step : int):
	queue.append(op | step)
	
# 执行移动
func move():
	var instruction = queue[0]
	var op = instruction & 0xFFFF0000
	var step = instruction & 0xFFFF
	queue.pop_front()
	is_moving = true
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
		return
	move()
	
func _ready():
	add_move(RIGHT, 5)
	add_move(DOWN, 5)
	add_move(LEFT, 2)
	add_move(UP, 2)

func _process(delta):
	if is_moving:
		if position == target:
			move_finished()	# 移动结束
		else:
			position = position.move_toward(target, delta * SPEED)	# 修改位置
	elif !queue.is_empty():
		move()
