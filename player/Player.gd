extends Node
#定义玩家的信息
enum PlayerStatus {WAITING, PLAYING, DEFEATED}
var players = []
#上一次操作的玩家
var operate_player: int = 0
var Status: String = "status"
var Index: String = "index"
var Name: String = "name"

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
			players.erase(player)
func erase_defeated():
	for player in players:
		if(player.status == PlayerStatus.DEFEATED):
			players.erase(player)
func get_players():
	return players
func get_player_size():
	return players.size()
func get_player_by_array_index(index: int):
	return players[index]
