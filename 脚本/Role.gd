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
var direction = Vector2i.ZERO

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
	
func add_move_by_vec(vec : Vector2i):
	if vec == Vector2i.LEFT:
		add_move(LEFT, 1)
	elif vec == Vector2i.RIGHT:
		add_move(RIGHT, 1)
	elif vec == Vector2i.UP:
		add_move(UP, 1)
	elif vec == Vector2i.DOWN:
		add_move(DOWN, 1)
		
# 执行移动
func move():
	var instruction = queue[0]
	var op = instruction & 0xFFFF0000
	var step = instruction & 0xFFFF
	queue.pop_front()
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
#	add_move(RIGHT, 5)
#	add_move(DOWN, 5)
#	add_move(LEFT, 2)
#	add_move(UP, 2)
	pass

func _process(delta):
	if is_moving:
		if position == target:
			move_finished()	# 移动结束
		else:
			position = position.move_toward(target, delta * SPEED)	# 修改位置
	elif !queue.is_empty():
		move()
