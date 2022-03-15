extends AnimatedSprite


export(String) var player_name = ""
func set_player_name(name: String):
	player_name = name
	$NameLabel.text = name
func get_player_name():
	return player_name
func _ready():
	
	
	pass 
