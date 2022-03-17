extends Node

signal on_bot_hit(source, index, pos)
var timeout = 5
func _ready():
	pass # Replace with function body.



func hit(source):
	var target = null
	var retry = 100
	while target == null || retry > 0:
		retry -=1		
		var players = Player.get_players()
		var availables = []
		for p in players:
			if(p.index != source.index):
				availables.append(p)
		target = availables[random_index(availables.size())]
	
	var hits = target.hit_positions
	var to_hit = target.rand_pos()
	if(hits.size() > 0):
		var one_hit = hits[random_index(hits.size())]
		var surrounds = source.get_surrounds(one_hit)
		if(surrounds.size() > 0):
			to_hit = surrounds[random_index(surrounds.size())]
	emit_signal("on_bot_hit", source, target.index, to_hit)	
func random_index(size: int):
	randomize()
	return randi() % size
