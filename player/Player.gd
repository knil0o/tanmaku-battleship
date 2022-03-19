extends Node
#定义玩家的信息
#WAITING 待机 ,PLAYING 回合中, 被击败 DEFEATED
enum PlayerStatus {WAITING, PLAYING, DEFEATED}
var players = []
#上一次操作的玩家
var operate_player: int = 0
var Status: String = "status"
var Index: String = "index"
var Name: String = "name"
var IsBot: String = "is_bot"

#用来传参的用户字典,这里初始化一个默认值
var player_payload = {
	Status: PlayerStatus.WAITING,
}
func get_default():
	return player_payload.duplicate(true)
func add_player(player):
	players.append(player)
func erase_by_index(index: int):
	for player in players:
		if(player.index == index):
			player.status = PlayerStatus.DEFEATED
func erase_defeated():
	for player in players:
		if(player.status == PlayerStatus.DEFEATED):
			players.erase(player)
func get_players():
	var not_defeated = []
	for player in players:
		if !is_instance_valid(player):
			return not_defeated
		if player.status != PlayerStatus.DEFEATED:
			not_defeated.append(player)
	return not_defeated
func get_player_size():
	return get_players().size()
func get_player_by_array_index(index: int):
	return get_players()[index]
func get_player(index: int):
	for player in players:
		if player.index == index:
			return player
func get_player_by_name(name: String):
	for player in players:
		if player.player_name == name:
			return player
func get_bots():
	var bots = []
	for player in get_players():
		if(player.is_bot):
			bots.append(player)
	return bots
func clear():
	players = []
#根据剩余格子数对比
static func compare_position_count(a, b) -> bool:
	if(!a.ship_positions):
		return false
	if(!b.ship_positions):
		return true	
	
	return a.ship_positions.size() < b.ship_positions.size()
#随机排序	
static func random_compare(a,b) -> bool:
	randomize()
	return (randi() % 100) % 3 == 1
func sort_by_positions():
	var players = get_players()
	print("original sort:", players[0].ship_positions, players[players.size()-1].ship_positions)
	players.sort_custom(Node, "compare_position_count")
	print("sorted: ", players[0].ship_positions, players[players.size()-1].ship_positions)
	return players
func sort_random():
	var players = get_players()
	print("original sort:", players[0].index, players[players.size()-1].index)
	players.sort_custom(Node, "random_compare")
	print("sorted: ", players[0].index, players[players.size()-1].index)
	return players	
func is_all_bot():
	var all_bot = true
	for player in players:
		all_bot = (player.is_bot && all_bot)
	return all_bot
