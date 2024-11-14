extends Node2D

var timer: float = 0
var peer_id
var ping: int = -1

func _ready() -> void:
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
		
func start_ping():
	#print(peer_id, " : start ping")
	timer = 0.001
	if peer_id == StaticLoad.multiplayer.get_unique_id():
		got_ping()
		return
	StaticLoad.rpc_id(peer_id, "check_ping")
	set_process(true)

func got_ping():
	set_process(false)
	ping = int(timer*1000)
	#print(peer_id, " : got ping : ", ping)
	if not StaticLoad.game.online_ui_vbox_container.has_node(str(peer_id)):
		var player_tmp = StaticLoad.online_peer_ids[peer_id]
		var online_info_instance = StaticLoad.online_info_scene.instantiate()
		StaticLoad.game.online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(peer_id)
		online_info_instance.player_name.text = player_tmp.player_name
	var online_info = StaticLoad.game.online_ui_vbox_container.get_node(str(peer_id))
	online_info.ping = ping
	online_info.update_ping()
	
