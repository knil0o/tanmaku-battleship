extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#定义发送的signal
signal click_pos(event)
export(PackedScene) var chess_board_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	print("!!!!!!!!!runing main scene!!!!!!!")
	var chess_board = chess_board_scene.instance()
	add_child(chess_board)
	chess_board.position = Vector2(16,32)
	#signal连接被调用的方法
	connect("click_pos", chess_board, "_on_click")
	pass # Replace with function body.

func _process(delta):
	pass
func _input(event):
	if event is InputEventMouseButton:
		#发送signal
		emit_signal("click_pos", event)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
