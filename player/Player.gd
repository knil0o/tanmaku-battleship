extends AnimatedSprite


var player_name = ""
var name_label
func set_player_name(name: String):
	player_name = name
	$NameLabel.text = name
func get_player_name():
	return player_name
	name_label = get_node("Label")
func _ready():
	
	
	pass 
