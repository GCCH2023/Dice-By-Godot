class_name Role
extends Node


# 图集属性
# 0 道路, 可以同行
# 1 障碍, 不可同行
# 如果图块的编号相同, 那么说明这些图块属于同一个建筑
# 100 表示空地, 可以购买
# 101~104表示属于1~4号玩家
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
	[1, 1, 1, 104, 103, 102, 101, 100],
]

const directions = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]

# 表示建筑的类
class Cell:
	var id:int		# 建筑的编号
	var role_id:int		# 建筑所属角色的id
	var pass_prop:int	# 通行属性
	var gold:int	# 购买所需金钱
	var map_rect:Rect2i	# 建筑在地图中的格子区域
	
	func _init():
		pass_prop = 0
		id = 0
		role_id = 0
		# 随机设置费用 [200, 500]
		gold = randi() % 300 + 200
		
	func can_pass()->bool:
		return pass_prop == 0

	func is_building():
		return pass_prop >= 100
		
# 地图属性数据, 二维数组, 元素类型是Building
var map  = []
# 当前角色
var current : Node2D

func gen_map():
	var layer_count = $TileMap.get_layers_count()
	var size = $TileMap.get_used_rect().size
	for y in range(0, size.y):
		map.append([])
		for x in range(0, size.x):
			var cell = Cell.new()
			for i in range(0, layer_count):
				var p =	$TileMap.get_cell_atlas_coords(i, Vector2i(x, y))	# 获取图块位置
				cell.map_rect = Rect2i(x, y, 1, 1)
				if p.x >= 0 && p.y >= 0 && cell.pass_prop < tile_set[p.y][p.x]:
					cell.pass_prop = tile_set[p.y][p.x]
			map[y].append(cell)

func get_building_role(cell:Cell):
	return $TileMap.get_role_by_id(cell.role_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	gen_map()
	var v = Vector2i(9, 3)
	var tile_set_pos = $TileMap.get_cell_atlas_coords(1, v)
	print(tile_set_pos)
	print("tile_set[1][2] = ", tile_set[tile_set_pos.y][tile_set_pos.x])
	print("map[1][2] = ",  map[v.y][v.x].pass_prop)
	print(get_move_one(Vector2i(9, 2), Vector2i.RIGHT))
	AnimationManager.set_main_camera($Node2D/Camera2D);
	AnimationManager.camera_switched.connect(camera_move_finished)
	var player = $TileMap.get_player()
	$CanvasLayer/ColorRect/HBoxContainer/Gold.text = str(player.get_money())
	role_turn($TileMap.get_player())
	
# 更改当前角色的资金, 返回是否成功
func change_current_role_gold(gold:int)->bool:
	if current.资金 + gold < 0:
		return false
	current.资金 += gold
	$CanvasLayer/ColorRect/HBoxContainer/Gold.text = str(current.资金)
	return true

# 获取格子对应的建筑
func get_building(point:Vector2i)->Cell:
	return map[point.y][point.x]

# 修改建筑的主人
func change_building_owner(building:Cell, role:Node2D):
	building.role_id = role.id
	# 修改地图显示
	$TileMap.set_cell(1, building.map_rect.position, 0, role.图块位置)
	print("修改建筑主人")

# 购买建筑
func buy_building(building:Cell):
	$CanvasLayer/ColorRect/HBoxContainer/Label.text = "%s 花费了 %d 购买了建筑" % [current.名称, building.gold]
	# 修改建筑所属
	change_building_owner(building, current)
	await get_tree().create_timer(0.5).timeout
	
# 尝试购买建筑
func try_buy_building(building:Cell):
	if change_current_role_gold(-building.gold):
		buy_building(building)

# 角色到达空地
func on_arrive_blank(building:Cell):
	print("到达空地")
	try_buy_building(building)
	
# 角色到达角色的地盘
func on_arrive_role_building(role:Node2D, building:Cell):
	print("到达", role.名称, "的地盘")
	# 扣除费用
	if change_current_role_gold(-building.gold):
		$CanvasLayer/ColorRect/HBoxContainer/Label.text = "%s 交取了 %d 的过路费" % [current.名称, building.gold]
	else:
		print("角色没钱了")

func on_role_move_end():
	# 判断角色位置周围是否有建筑
	var role_pos = $TileMap.get_role_position(current)
	for vec in directions:
		var point = role_pos + vec
		var cell = map[point.y][point.x]
		if cell.is_building():
			var role = $TileMap.get_role_by_id(cell.role_id)
			if role == null:
				on_arrive_blank(cell)
			else:
				on_arrive_role_building(role, cell)
			# 应该一个格子只能对应一个建筑, 所以break了
			break

	# 切换相机节点
	#相机节点.position = current.position
	$Node2D/Camera2D.make_current()
	switch_role()

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
		if map[next_pos.y][next_pos.x].can_pass():
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
	var role_pos = $TileMap.get_role_position(role)
	var direction = $TileMap.get_role_direction(role)
	print("角色 ", role.名称, " 位置 : ", role_pos, " 朝向 : ", direction)
	
#	role_pos = Vector2i(3, 10)
#	direction = Vector2.LEFT
#	step = 3
	var last_vec = Vector2i.ZERO
	var count = 0
	for i in range(0, step):
		var can_pass_vecs = get_move_one(role_pos, direction)	# 可同行向量
		# 如果有多个可通行向量, 则随机选择一个
		var v = can_pass_vecs[randi_range(0, can_pass_vecs.size() - 1)]
		# 尝试合并当前向量和上一个向量
		if v == last_vec:
			count += 1
		else:
			if count > 0:
				role.add_move_by_vec(last_vec, count)
			last_vec = v
			count = 1
		role_pos += v
		direction = v
	
	if count > 0:
		role.add_move_by_vec(last_vec, count)
	
func show_player_panel():
	$CanvasLayer/ColorRect/HBoxContainer/Button.disabled = false
	
	
var camera_finished_need_wait:bool=false
func camera_move_finished():
	# 切换相机父节点
	current.set_camera()
	
	if camera_finished_need_wait:
		await get_tree().create_timer(0.5).timeout
	else:
		camera_finished_need_wait = true
	
	$CanvasLayer/ColorRect/HBoxContainer/Gold.text = str(current.get_money())
	if current.是否玩家:
		print("\n开始玩家 ", current.名称, " 的回合")
		show_player_panel()
	else:
		print("\n开始电脑 ", current.名称, " 的回合")
		dice_and_move()
	
# 开始指定玩家的回合
func role_turn(role : Node2D):
	var cur_camera = current.get_camera() if current != null else null
	var duration = 0 if camera_finished_need_wait == false else 1
	AnimationManager.switch_camera(cur_camera, role.get_camera(), duration)
	current = role
	# 摄像机移动到角色中心
	#var anim = AnimationManager.move_to($Node2D, role.global_position, 1)
	#anim.finished.connect(camera_move_finished)
	
# 切换到下一个玩家
func switch_role():
	role_turn(current.next)
	
func dice_and_move():
	var n = randi_range(1, 6)
	print("骰子掷出了", n, "点")
	$CanvasLayer/ColorRect/HBoxContainer/Label.text = "%s 骰子掷出了 %d 点" % [current.名称, n]
	# 生成移动路线
	move_role(current, n)
	
# 前进
func on_forward_pressed():
	if current == $TileMap.get_player():
		$CanvasLayer/ColorRect/HBoxContainer/Button.disabled = true
		dice_and_move()
	
