extends TileMap

signal move_end

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(get_cell_source_id(0, Vector2i(0, 0)))
#	print(get_cell_source_id(0, Vector2i(1, 1)))
#	var size = get_used_rect().size
#	print("地图大小", size.x,' * ', size.y)
#	set_cell(0, Vector2i(0, 0), 0, Vector2i(4, 0))
#	print(get_cell_atlas_coords(0, Vector2i(0, 0)))
#	print(local_to_map(Vector2i(35, 15)))
#	print("主角位置: ", $Role.position)
#	print("主角格子: ", get_role_position(0))
	
	var children = get_children()
	for i in range(0, children.size()):
		children[i].next = children[(i + 1) % children.size()]
		children[i].prev = children[(i + children.size() -1) % children.size()]
		children[i].move_end.connect(on_role_move_end)
	print($Role.next.名称)

func on_role_move_end(role : Node2D):
	print("角色 ", role.名称, " 回合结束")
	await get_tree().create_timer(0.5).timeout
	emit_signal("move_end")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_role_position(role : Node2D):
	return local_to_map(role.position)
	
func get_role_direction(role : Node2D):
	return role.direction
	
func get_player() -> Node2D:
	return $Role

