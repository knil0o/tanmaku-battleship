extends TileMap
export(PackedScene) var ship_scene
export(PackedScene) var attacked_sea_scene
export(PackedScene) var sea_scene
#棋盘大小
var chess_board_scale = Vector2(9, 9)
#普通海域tile id
var normal_ground = 1
#被攻击海域tile id
var attacked_ground = 2
#单个tile大小
var tile_size = 16
#所有船的大小
var ship_yard = [
	Vector2(1,1),  Vector2(1,1),
	Vector2(2,1), Vector2(1,2),
	Vector2(1,3), Vector2(3,1),
	Vector2(1,4)
]
#放置的数据
var placed = []

var ship_positions = []
var lock_positions = []
var hit_positions = []
func _ready():

	
#	for cell in get_used_cells():
#		print("x: "+ str(cell.x) + "y: " + str(cell.y))
	
	var ship = ship_scene.instance()
	place_tile(chess_board_scale)
#	show_ship(ship, 1, 1, Vector2(5,2))
	place_ships(ship_yard)
	print("ship_positions:" + str(ship_positions))

#攻击一个位置范围,返回剩余位置
func hit(hit_pos: Vector2):
	for ship_pos in ship_positions:
		if(ship_pos == hit_pos):
			#击中了
			ship_positions.erase(ship_pos)
			print("now has" + str(ship_positions))
			set_cellv(hit_pos, 0)
			return ship_positions
		elif(!hit_positions.has(hit_pos)):
			set_cellv(hit_pos, 2)
			hit_positions.append(hit_pos)
		
func get_ship_prositions():
	return ship_positions

func has_ship():
	return get_ship_prositions().size() > 0

#收到点击事件
func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_pos = event.position - position
		var tile_pos = world_to_map(mouse_pos)
		if(tile_pos.x <= chess_board_scale.x && tile_pos.y <= chess_board_scale.y && tile_pos.x >= 0 && tile_pos.y >= 0):
			hit(world_to_map(mouse_pos))
	
	
func _process(delta):
	pass

func place_ships(ships):
	for ship_size in ships:
		place_one(ship_size, rand_pos())

#增加一个船位置
func place_one(ship: Vector2, pos: Vector2):
	#以左上方为pos点，开始绘制
	#先判断是否能绘制，不能就随机找位置
	var retry = 50
	var can_deploy = try_place(ship, pos)
	while !can_deploy:
		pos = rand_pos()
		can_deploy = try_place(ship, pos)
		retry = retry -1
		if(retry < 0):
			#重试次数过多，重新加载当前场景
			get_tree().reload_current_scene()
	
	
	var pos_origin = Vector2(pos.x, pos.y)
	while pos.x < (ship.x + pos_origin.x):
		while pos.y < (ship.y + pos_origin.y):
			var draw_pos= Vector2(pos.x, pos.y)
			print("ship placed in " + str(draw_pos))
			ship_positions.append(draw_pos)
			add_surround_lock(draw_pos)
			pos.y += 1
		pos.y = pos_origin.y
		pos.x += 1

# 船周围一格不能放置，增加锁定坐标
func add_surround_lock(pos: Vector2):
	var locks = [
		pos, 
		pos + Vector2.LEFT,
		pos + Vector2.RIGHT,
		pos + Vector2.UP,
		pos + Vector2.DOWN,
		pos + Vector2(1,1),
		pos + Vector2(-1,1),
		pos + Vector2(1,-1),
		pos + Vector2(-1,-1),
	]
	lock_positions.append_array(locks)	
# 查询船是否能放置在这里,如果超过范围就减少
func try_place(ship: Vector2, try_pos: Vector2):

	var pos_origin = Vector2(try_pos.x, try_pos.y)
	while try_pos.x < (ship.x + pos_origin.x):
		while try_pos.y < (ship.y + pos_origin.y):
			for lock_pos in lock_positions:
				#不能放在限制位置也不能超过棋盘
				var out_of_range = try_pos.x > chess_board_scale.x || try_pos.y > chess_board_scale.y
				#print("out of range:" +str(try_pos))
				if (lock_pos.x == try_pos.x && lock_pos.y == try_pos.y) || out_of_range :
					print("ship cannot placed in " + str(try_pos))
					return false
			try_pos.y += 1
		try_pos.y = pos_origin.y
		try_pos.x += 1
	return true

#布置一个战舰位置
func show_ship(ship, scale_x, scale_y, map_pos: Vector2):
	add_child(ship)
	ship.position = pos_into_cell(map_to_world(map_pos))
func place_tile(chess_board_scale):
	for x in chess_board_scale.x +1:
		for y in chess_board_scale.y +1:
			set_cell(x, y, 1)
	
func pos_into_cell(pos: Vector2):
	pos.snapped(Vector2.ONE * tile_size)
	pos += Vector2.ONE * tile_size/2
	return pos
	
#返回一个0-9的随机位置
func rand_pos():
	#重要！否则不会随机生成
	randomize()
	return Vector2(randi()%10, randi()%10)
	
