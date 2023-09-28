extends Node2D

# 定义一个二维数组作为关卡地图
var levelMap = [
	[1, 1, 1, 1, 1],
	[1, 0, 0, 0, 1],
	[1, 0, 2, 0, 1],
	[1, 0, 3, 0, 1],
	[1, 1, 1, 1, 1]
]

# 生成关卡的函数
func generateLevel():
	for y in range(levelMap.size()):
		for x in range(levelMap[y].size()):
			var tileType = levelMap[y][x]
			if tileType == 1:
				# 绘制墙壁矩形
				draw_rect(Rect2(x * 32, y * 32, 32, 32), Color.GREEN)
			elif tileType == 2:
				# 绘制玩家矩形
				draw_rect(Rect2(x * 32, y * 32, 32, 32), Color.RED)
			elif tileType == 3:
				# 绘制箱子矩形
				draw_rect(Rect2(x * 32, y * 32, 32, 32), Color.BLUE)

func _draw():
	self.generateLevel()

func _process(delta):
	queue_redraw()
