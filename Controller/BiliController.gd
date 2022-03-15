extends Node
# The URL we will connect to
export(String) var room_url = "https://live.bilibili.com/23848025?hotRank=0&session_id=a57af09ab51d3aec8885cb9fcda58fdf_50152752-3361-46A7-82B8-FF0419C1CC36&visit_id=3cnd699zwk80"
export(String) var websocket_url = "ws://localhost:7852/"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var last_msg_time
var expire_s = 10

signal on_msg_expire
signal on_hit_pos(player_name, pos)
signal on_player_in(player_name)

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

func _on_data():
	last_msg_time = OS.get_time()
	var json = _client.get_peer(1).get_packet().get_string_from_utf8();
	print("Got data from server: ", json)
	var dict = JSON.parse(json).get_result()
	if(dict["content"] == "加入"):
		emit_signal("on_player_in", dict["name"])

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
