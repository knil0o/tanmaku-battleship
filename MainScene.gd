extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#定义发送的signal
signal click_pos(event)
export(PackedScene) var chess_board_scene
export(PackedScene) var player_scene
var chess_board1
var chess_board2
var player1

# Called when the node enters the scene tree for the first time.
func _ready():
	chess_board1 = chess_board_scene.instance()
	chess_board2 = chess_board_scene.instance()
	add_child(chess_board1)
	add_child(chess_board2)
	chess_board1.position = Vector2(64,32)
	chess_board2.position = Vector2(256,32)
	
	player1 = player_scene.instance()
	add_child(player1)
	player1.set_player_name("vdv_v少")
	
	
	pass 

func _process(delta):
	player1.position = lerp(Vector2(64,64),Vector2(128,256), 0.01)
	pass
