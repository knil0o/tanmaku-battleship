extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#定义发送的signal
signal click_pos(event)
export(PackedScene) var chess_board_scene
export(PackedScene) var player_scene
export(PackedScene) var controller
export(int) var start_wait_time = 5
export(int) var turn_wait_time = 30
export(float) var cheess_board_offset = 100
export(int) var max_player_count = 6
var players = []
#上一次操作的玩家
var operate_player: int = 0
#回合数
var turn_count = 0
#每个回合的时间
var turn_time = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass 



func _process(delta):
	
	if(start_wait_time == 0):
		while players.size() < max_player_count:
			add_player("老爷"+ str(randi()))
		
		game_start()

	if(start_wait_time < 0):
		$HUD.set_wait_start_text("第"+ str(turn_count +1) + "回合剩余时间" + str(floor($TurnTimer.time_left) + 1))


func _on_WaitPlayerTimer_timeout():
	$HUD.set_wait_start_second(start_wait_time)
	start_wait_time -= 1



func game_start():
	print("game start")
	#重要！否则重复调用
	start_wait_time -=1

	get_tree().call_group("start", "queue_free")
	#下面是游戏逻辑
	var path_position = $Path/Follow
	$Path.curve.add_point(Vector2(0, 0), Vector2(100, 0))
	for player in players:
		path_position.offset += cheess_board_offset
		var chess_board = chess_board_scene.instance()
		add_child(chess_board)
		chess_board.position = path_position.position
		print("path" + str(path_position.position))
		print(path_position.get_offset())
	
	#棋盘生成完毕后，启动回合计时器
	yield(get_tree().create_timer(1), "timeout")
	start_turn_timer()

	#chess_board1 = chess_board_scene.instance()
	#chess_board2 = chess_board_scene.instance()
	#add_child(chess_board1)
	#add_child(chess_board2)
	#chess_board1.position = Vector2(64,32)
	#chess_board2.position = Vector2(256,32)
#切换到玩家的回合
func set_player_turn(player: String):
	$HUD.set_current_player(player)
func set_player_turn_index(index: int):
	var player_name = players[min(index, players.size() - 1)]
	set_player_turn(player_name)

#回合超时后进行下一回合
func _on_TurnTimer_timeout():
	#回合数 mod 人数 = 当前玩家在数组中的index
	operate_player = turn_count % players.size()
	set_player_turn_index(operate_player)
	turn_count += 1
#用户操作后进入下一回合	
	
#设置回合计时器并开始
func start_turn_timer():
	$TurnTimer.set_wait_time(turn_time)
	$TurnTimer.start()
	turn_count = 0;
#在计时器结束之前，进入下一回合
func next_turn():
	operate_player += 1
	turn_count += 1
	set_player_turn_index(operate_player)
	#计时器重新开始
	$TurnTimer.start()



#玩家输入指令
func _on_WsController_on_hit_pos(player_name, pos, target):
	pass


#加入玩家
func _on_WsController_on_player_in(player_name):
	add_player(player_name)
	
func add_player(name: String):
	players.append(name)
	$HUD.add_player(name)
