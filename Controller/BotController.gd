extends Node

signal on_bot_hit(source, index, pos)
var timeout = 5
func _ready():
	pass # Replace with function body.
func get_whom(source):
	var players = Player.get_players()
	var availables = []
	for p in players:
		if(p.index != source.index):
			availables.append(p)
	randomize()
	if availables.size() == 0:
		return null
	return availables[randi() % availables.size()]
# 随机得到被击中的船的位置
func get_hit_pos(target):
	var hits = target.hit_positions
	var ships = target.ship_positions
	var hitables = []
	for ship in ships:
		for hit in hits:
			var surrounds = target.get_surrounds(hit)
			if ship == hit:
				print("ship is hit:", ship == hit, "ship ", ship, "hit ", hit)
			if (ship.x == hit.x || ship.y == hit.y) && surrounds.size() > 0:
				hitables.append_array(surrounds)
	#随机取一个位置
	print(target.player_name, " surrounds: ", hitables)
	randomize()

	if hitables.size() == 0:
		return target.rand_pos()
	if target.ship_positions.size() == 0:
		return null
		
	return hitables[randi() % hitables.size()]
	
func hit(source):

	var target = get_whom(source);
	if !target:
		return
	var hits = target.hit_positions
	var to_hit = get_hit_pos(target)
	if !to_hit:
		return
	emit_signal("on_bot_hit", source, target.index, to_hit)	
func random_index(size: int):
	randomize()
	return randi() % size
