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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
