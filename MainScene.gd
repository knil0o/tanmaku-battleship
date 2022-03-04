extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#定义发送的signal
signal click_pos(event)
export(PackedScene) var chess_board_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	var chess_board1 = chess_board_scene.instance()
	var chess_board2 = chess_board_scene.instance()
	add_child(chess_board1)
	add_child(chess_board2)
	chess_board1.position = Vector2(64,32)
	chess_board2.position = Vector2(256,32)
	pass 

func _process(delta):
	pass


