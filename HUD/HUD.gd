extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_head_line = "当前玩家:"

# Called when the node enters the scene tree for the first time.
func _ready():
	$CurrentPlayer/PlayerInfo.text = "加入的玩家\n"
	
	pass # Replace with function body.

func set_wait_start_text(hint: String):
	$TimerText.set_text(hint)
func set_wait_start_second(second: int):
	$TimerText.set_text("弹幕发送“加入”参赛！， 距离游戏开始还剩" +str(second) + "秒")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_players(players: PoolStringArray):
	for player_name in players:
		add_player(player_name)
func set_current_player(player_name: String):
	$CurrentPlayer.text = player_head_line + player_name
func add_player(player: String):
	$CurrentPlayer/PlayerInfo.text +=  player +"\n"