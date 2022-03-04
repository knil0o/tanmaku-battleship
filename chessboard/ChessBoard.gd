extends TileMap
export(PackedScene) var ship_scene
export(PackedScene) var attacked_sea_scene
export(PackedScene) var sea_scene

var chess_board_scale = Vector2(10, 10)

var normal_ground = 1
var attacked_ground = 2
func _ready():
	for cell in get_used_cells():
		print("x: "+ str(cell.x) + "y: " + str(cell.y))
	
	var ship = ship_scene.instance()
	place_tile(chess_board_scale)
	
	#add_child(ship)
	#place_ship(ship, 1, 1, Vector2(0,1))


#点击事件(MainScene发送的)
func _on_click(event):
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_pos = map_to_world(world_to_map(mouse_pos))
	print("click world_to_map" + str(world_to_map(mouse_pos)))
	print("click" + str(tile_pos.x) + ", " + str(tile_pos.y))
	var ats = attacked_sea_scene.instance()
	

func place_ship(ship, scale_x, scale_y, map_pos: Vector2):
	ship.position = map_to_world(map_pos)
	
func place_tile(chess_board_scale):
	for x in chess_board_scale.x:
		for y in chess_board_scale.y:
			var sea_tile = sea_scene.instance()
			add_child(sea_tile)
			sea_tile.position = Vector2(x, y)
	
