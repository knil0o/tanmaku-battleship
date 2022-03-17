extends Node
# The URL we will connect to
export(String) var room_url = "http://live.bilibili.com/6249349"
export(String) var websocket_url = "ws://localhost:7852/"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var last_msg_time
var expire_s = 10

signal on_msg_expire
signal on_hit_pos(player_name, pos, target)
signal on_player_in(player_name)
signal on_error(message)
func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url+room_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	last_msg_time = OS.get_time()
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())
#弹幕发送“加入”加入本轮游戏，回合中发送玩家编号和棋盘坐标攻击（如："1，j,8"，攻击编号为1的玩家的坐标为j,8的格子）忽略大小写
func _on_data():
	
	last_msg_time = OS.get_time()
	var json = _client.get_peer(1).get_packet().get_string_from_utf8();
	print("Got data from server: {}, {}", json , OS.get_datetime())
	var dict = JSON.parse(json).get_result()
	var error
	var content = dict["content"].to_lower().strip_escapes()
	var player_name = dict["name"]
	content = content.replace("，", ",")
	
	var is_pos = content.find(",") != -1

	if(content == "加入" || content == "jiaru"):
		emit_signal("on_player_in", player_name)
	elif(is_pos):
		var pos_arr = content.split(",")
		if(pos_arr.size() < 3):
			return
		var player_index = int(pos_arr[0])
		if (!pos_arr[2].is_valid_integer()):
			print("y坐标输入错误", pos_arr[2])
			return
		
		var pos_y = max(int(pos_arr[2]) -1, 0)
		var pos_char = pos_arr[1]
		var pos_x = char_to_pos(pos_char)
		if (typeof(pos_x) != TYPE_INT):
			print("x坐标输入错误", typeof(pos_x), "!=", TYPE_INT)
			return
		var real_pos = Vector2(pos_x, pos_y)
		print("转化后的坐标 ", real_pos)
		emit_signal("on_hit_pos", player_name, real_pos, player_index)
		
func char_to_pos(aj: String):
	var array = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
	for chara in array:
		if chara == aj:
			return array.find(chara)

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
