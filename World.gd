extends Node
var status = WorldStatus.WAITING_FOR_GAMER

enum WorldStatus {
	WAITING_FOR_GAMER,
	PLAYING,
	END
	
}
func clear():
	status = WorldStatus.WAITING_FOR_GAMER
