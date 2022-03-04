extends TileMap
export(PackedScene) var ship_scene
export(PackedScene) var attacked_sea_scene
export(PackedScene) var sea_scene

var chess_board_scale = Vector2(10, 10)

var normal_ground = 1
var attacked_ground = 2
var tile_size = 16
var item_offset = tile_size / 2

func _ready():
#	for cell in get_used_cells():
#		print("x: "+ str(cell.x) + "y: " + str(cell.y))
	
	var ship = ship_scene.instance()
	place_tile(chess_board_scale)
	place_ship(ship, 1, 1, Vector2(5,2))



#收到点击事件
func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_pos = event.position - position
		var tile_pos = world_to_map(mouse_pos)
		print("click world_to_map" + str(world_to_map(mouse_pos)))
		print("click" + str(tile_pos.x) + ", " + str(tile_pos.y))
		var ats = attacked_sea_scene.instance()
		set_cellv(world_to_map(mouse_pos), 2)
	
func _process(delta):
	set_cell(2,2,2)


func place_ship(ship, scale_x, scale_y, map_pos: Vector2):
	add_child(ship)
	ship.position = pos_into_cell(map_to_world(map_pos))
func place_tile(chess_board_scale):
	for x in chess_board_scale.x:
		for y in chess_board_scale.y:
			set_cell(x, y, 1)
	
func pos_into_cell(pos: Vector2):
	pos.snapped(Vector2.ONE * tile_size)
	pos += Vector2.ONE * tile_size/2
	return pos
	
