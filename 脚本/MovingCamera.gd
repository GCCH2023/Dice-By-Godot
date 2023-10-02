extends Node2D
# 表示可移动的摄像机

@export var 速度 = 10

signal move_finished

var target = Vector2.ZERO
var is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position != target && is_moving:
		position += (target - position).normalized() * 速度

func move_to(vec : Vector2):
	if position != vec:
		target = vec
		is_moving = true
