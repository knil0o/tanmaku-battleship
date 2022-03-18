extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#定义发送的signal
export(PackedScene) var chess_board_scene
export(PackedScene) var player_scene
export(PackedScene) var controller
export(int) var start_wait_time = 5
export(int) var turn_wait_time = 30
export(float) var cheess_board_offset = 100
export(int) var max_player_count = 6
export(int) var msg_show_time = 10

#这里保存chess_board_scene的数组

#回合数
var turn_count = 0
#每个回合的时间

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.status = Global.WorldStatus.WAITING_FOR_GAMER
func add_player(payload: Dictionary):
	var board = chess_board_scene.instance()
	board.set_player_info(payload)
	Player.add_player(board)
	add_child(board)
	return board
func _process(delta):
	if(start_wait_time == 0):
		var current_index = 1
		while Player.players.size() < max_player_count:
			#生成电脑玩家

			var player = Player.get_default()
			player[Player.Index] = current_index
			player[Player.Name] = str(randi()) + "号老鸭"
			player[Player.Status] = Player.PlayerStatus.WAITING
			player[Player.IsBot] = true
			var board = add_player(player)
			board.hide()
			
			print("加入玩家",board)
			current_index += 1
			
		game_start()
		next_turn()

		
		print("players:", Player.players)
	try_end_game()
	if(start_wait_time < 0):
		$HUD.set_wait_start_text("第"+ str(turn_count +1) + "回合剩余时间" + str(floor($TurnTimer.time_left) + 1))
	

func _on_WaitPlayerTimer_timeout():
	$HUD.set_wait_start_second(start_wait_time)
	start_wait_time -= 1


func try_end_game():
	if(Player.get_player_size() == 1 && Global.status == Global.WorldStatus.PLAYING):
		Global.status = Global.WorldStatus.END
		yield(get_tree().create_timer(msg_show_time), "timeout")
		$TurnTimer.stop()
		restart()



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
	#重新设置编号
	var current_id = 1
	for board in Player.players:
		if !is_instance_valid(board):
			continue
		board.show()
		board.index = current_id
		current_id += 1
		path_position.offset += cheess_board_offset
		board.position = path_position.position
	
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
	if(board.is_bot):
		$BotController.hit(board)
				
func set_player_turn_index(index: int):
	var player = Player.get_player_by_array_index(min(index, Player.get_player_size() - 1))
	set_player_turn(player)

#回合超时后进行下一回合
func _on_TurnTimer_timeout():
	
	next_turn()
	
#用户操作后进入下一回合	
func next_turn():
	var player_count = Player.get_player_size()
	
	if Global.status == Global.WorldStatus.END:
		return
	if player_count == 0:
		return	
	
	$TurnTimer.start()
	print("第",turn_count,"回合， 剩余玩家", Player.get_player_size())
	print("剩余玩家", Player.get_players())
	print("全部玩家", Player.players)
	Player.operate_player = turn_count % Player.get_player_size()
	set_player_turn_index(Player.operate_player)
	turn_count += 1	
#设置回合计时器并开始
func start_turn_timer():
	$TurnTimer.set_wait_time(turn_wait_time)
	$TurnTimer.start()
	turn_count = 0;


#玩家输入指令
func _on_WsController_on_hit_pos(player_name, pos, index):
	var board = Player.get_player(index)
	var player = Player.get_player_by_name(player_name)
	var can_opt = true
	
	if !player:
		alert(player_name + " 你还没加入游戏")
		return
	if !is_instance_valid(board):
		alert(player_name + "输入的编号错误❌")
	if board.player_name == player_name:
		alert(player_name + " 自己人！")
		can_opt = false
	if player.status != Global.WorldStatus.PLAYING:
		alert("还没到" + player_name + "的回合")
		can_opt = false
	if Global.status != Global.WorldStatus.PLAYING:
		alert("现在不能操作")
		can_opt = false
	if !can_opt:
		return
	print(player_name, "攻击", board.player_name)
	hit(board, pos)
	next_turn()

func hit(board, pos):
	var is_hit = false
	if(board != null && board.status == Player.PlayerStatus.WAITING):
		board.hit(pos)
	if(is_hit):
		print("恭喜")
	return is_hit
	
#加入玩家
func _on_WsController_on_player_in(player_name):
	#
	
	#用名字创建玩家
	var new_player = {Player.Name: player_name, Player.Status: Player.PlayerStatus.WAITING}
	var board = add_player(new_player)
	board.hide()
func alert(msg: String):
	print("WARN!!! ", msg)
	
	pass
func restart():
	get_tree().reload_current_scene()
	Player.clear()
	Global.clear()


func _on_BotController_on_bot_hit(source, index, pos):
	var board = Player.get_player(index)
	print(source.player_name, "(机器人)攻击", board.player_name, "状态", board.status, "位置：", pos)
	
	hit(board, pos)
	yield(get_tree().create_timer(1), "timeout")
	
	next_turn()
	pass # Replace with function body.
