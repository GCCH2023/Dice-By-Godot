class_name Role
extends Node


# 图集属性
# 0 道路, 可以同行
# 1 障碍, 不可同行
# 1001 空地, 可以占有
# tilemap 中可能有多个图层, 如果多个图层都有图块, 那么取大的那个值
const tile_set = [
	[0, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1001],
]

const directions = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]

# 地图属性数据
var map = []

func gen_map():
	var layer_count = $TileMap.get_layers_count()
	var size = $TileMap.get_used_rect().size
	for y in range(0, size.y):
		map.append([])
		for x in range(0, size.x):
			map[y].append(-1)
			for i in range(0, layer_count):
				var p =	$TileMap.get_cell_atlas_coords(i, Vector2i(x, y))	# 获取图块位置
				if p.x >= 0 && p.y >= 0 && map[y][x] < tile_set[p.y][p.x]:
					map[y][x] = tile_set[p.y][p.x]

# Called when the node enters the scene tree for the first time.
func _ready():
	gen_map()
	var v = Vector2i(9, 3)
	var tile_set_pos = $TileMap.get_cell_atlas_coords(1, v)
	print(tile_set_pos)
	print("tile_set[1][2] = ", tile_set[tile_set_pos.y][tile_set_pos.x])
	print("map[1][2] = ",  map[v.y][v.x])
	print(get_move_one(Vector2i(9, 2), Vector2i.RIGHT))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# 获取可以同行的3个方向
func get_next_directions(direction):
	print("反方向: ", -direction)
	return directions.filter(func(d): return d != -direction)

# 获取指定位置和朝向可以移动的向量数组
func get_move_one(pos : Vector2i, dir : Vector2i):
	print("获取邻接位置:")
	var next_dirs = get_next_directions(dir)
	var can_pass_vecs = []	# 可同行向量
	for vec in next_dirs:
		var next_pos = pos + vec
		# 判断下一个位置是否可通行
		if map[next_pos.y][next_pos.x] == 0:
			print(next_pos," : 可通行")
			can_pass_vecs.append(vec)
		else:
			print(next_pos," : 不可通行")
	
	if can_pass_vecs.is_empty():
		print("无路可走")
		dir = -dir
		can_pass_vecs.append(dir)
	return can_pass_vecs
			
func move_role(role : Node2D, step : int):
	var role_pos = $TileMap.get_role_position(0)
	print("主角位置 : ", role_pos)
	var direction = $TileMap.get_role_direction(0)
	print("主角朝向: ", direction)
	
	for i in range(0, step):
		var can_pass_vecs = get_move_one(role_pos, direction)	# 可同行向量
		# 如果有多个可通行向量, 则随机选择一个
		var v = can_pass_vecs[randi_range(0, can_pass_vecs.size() - 1)]
		role.add_move_by_vec(v)
		role_pos += v
		direction = v
	
# 前进
func on_forward_pressed():
	var n = randi_range(1, 6)
	print("骰子掷出了", n, "点")
	
	
	
	# 生成移动路线
	move_role($TileMap/Role, n)
