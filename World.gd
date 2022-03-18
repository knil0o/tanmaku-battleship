extends Node
var status = WorldStatus.WAITING_FOR_GAMER
var bot_names = [
	"猪肉鲜虾肠", "腐竹螺蛳粉", "鸡蛋炒米粉", "紫金八刀汤", "土豆回锅肉", "叉烧拼烧鸭"	
]


enum WorldStatus {
	WAITING_FOR_GAMER,
	PLAYING,
	END
	
}
func clear():
	status = WorldStatus.WAITING_FOR_GAMER
