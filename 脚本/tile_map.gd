extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_cell_source_id(0, Vector2i(0, 0)))
	print(get_cell_source_id(0, Vector2i(1, 1)))
	var size = get_used_rect().size
	print("地图大小", size.x,' * ', size.y)
	set_cell(0, Vector2i(0, 0), 0, Vector2i(4, 0))
	print(get_cell_atlas_coords(0, Vector2i(0, 0)))
	print(local_to_map(Vector2i(35, 15)))
	print("主角位置: ", $Role.position)
	print("主角格子: ", get_role_position(0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_role_position(index):
	if index == 0 :
		return local_to_map($Role.position)
	elif index == 1:
		return local_to_map($Role1.position)
	elif index == 2:
		return local_to_map($Role2.position)
	elif index == 3:
		return local_to_map($Role3.position)
	
func get_role_direction(index):
	if index == 0 :
		return $Role.direction
	elif index == 1:
		return $Role1.direction
	elif index == 2:
		return $Role2.direction
	elif index == 3:
		return $Role3.direction

