extends HSplitContainer

@onready var player_name = $PlayerName
@onready var animation =  $Signal/animation

var ping: int = -1

func update_ping():
	if ping > 0:
		animation.animation = "signal"
		animation.frame = StaticLoad.get_level_by_ping(ping)
	else:
		animation.animation = "disconnect"
	
