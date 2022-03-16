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
#这里保存chess_board_scene的数组

#回合数
var turn_count = 0
#每个回合的时间
var turn_time = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.status = Global.WorldStatus.WAITING_FOR_GAMER

func _process(delta):
	$HUD.show_players()
	Player.erase_defeated()
	if(start_wait_time == 0):
		var current_index = 1
		while Player.get_player_size() < max_player_count:
			#生成电脑玩家
			var board = chess_board_scene.instance()
			add_child(board)
			var player = Player.get_default()
			player[Player.Index] = current_index
			player[Player.Name] = str(randi()) + "号老鸭"
			player[Player.Status] = Player.PlayerStatus.WAITING
			board.set_player_info(player)
			board.hide()
			
			print("加入玩家",board)
			Player.add_player(board)
			current_index += 1
			
		game_start()

	if(start_wait_time < 0):
		$HUD.set_wait_start_text("第"+ str(turn_count +1) + "回合剩余时间" + str(floor($TurnTimer.time_left) + 1))
	

func _on_WaitPlayerTimer_timeout():
	$HUD.set_wait_start_second(start_wait_time)
	start_wait_time -= 1


func try_end_game():
	if(Player.get_player_size() == 1 && Global.status == Global.WorldStatus.PLAYING):
		Global.status = Global.WorldStatus.END


func game_start():
	print("game start")
	#重要！否则重复调用
	start_wait_time -=1
	#设置全局状态为PLAYING
	Global.status = Global.WorldStatus.PLAYING
	yield(get_tree().create_timer(1), "timeout")
	get_tree().call_group("start", "queue_free")
	#下面是游戏逻辑
	var path_position = $Path/Follow
	$Path.curve.add_point(Vector2(0, 0), Vector2(100, 0))
	for board in Player.get_players():
		board.show()
		path_position.offset += cheess_board_offset
		board.position = path_position.position
		print("path" + str(path_position.position))
		print(path_position.get_offset())
	
	#棋盘生成完毕后，启动回合计时器
	start_turn_timer()

	#chess_board1 = chess_board_scene.instance()
	#chess_board2 = chess_board_scene.instance()
	#add_child(chess_board1)
	#add_child(chess_board2)
	#chess_board1.position = Vector2(64,32)
	#chess_board2.position = Vector2(256,32)
#切换到玩家的回合
func set_player_turn(board):
	board.status = Player.PlayerStatus.PLAYING
	for other in Player.get_players():
			if other.index != board.index:
				other.status = Player.PlayerStatus.WAITING
				other.show_player()
	$HUD.set_current_player(board)
func set_player_turn_index(index: int):
	var player = Player.get_player_by_array_index(min(index, Player.get_player_size() - 1))
	set_player_turn(player)

#回合超时后进行下一回合
func _on_TurnTimer_timeout():
	#回合数 mod 人数 = 当前玩家在数组中的index
	print("第",turn_count,"回合， 剩余玩家", Player.get_player_size())
	Player.operate_player = turn_count % Player.get_player_size()
	set_player_turn_index(Player.operate_player)
	turn_count += 1
#用户操作后进入下一回合	
	
#设置回合计时器并开始
func start_turn_timer():
	$TurnTimer.set_wait_time(turn_time)
	$TurnTimer.start()
	turn_count = 0;


#玩家输入指令
func _on_WsController_on_hit_pos(player_name, pos, target):
	pass
	
func hit(pos, index):
	pass
	
	

#加入玩家
func _on_WsController_on_player_in(player_name):
	#用名字创建玩家
	var new_player = {Player.NAME: player_name, Player.STATUS: Player.PlayerStatus.WAITING}
	var board = chess_board_scene.instance()
	board.set_player_info(new_player)
	Player.add_player(board)

