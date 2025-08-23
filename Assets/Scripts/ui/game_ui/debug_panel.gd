extends Control

@onready var debug_vflow_container = $VFlowContainer

func _process(delta: float) -> void:
	debug_vflow_container.get_node("PlayerName").text = tr("PLAYER_NAME")+" : "+ClientManager.local_player.player_name
	var local_player_coordinate = WorldTransformer.get_block_coordinate(ClientManager.local_player.position)
	debug_vflow_container.get_node("Coordinate").text = tr("COORDINATE")+" : x="+str(local_player_coordinate[0])+", y="+str(-local_player_coordinate[1])
	var real_mouse_position = get_global_mouse_position()
	if ClientManager.local_player != null and ClientManager.local_player.gamemode != "creative":
		real_mouse_position = WorldTransformer.get_restricted_block_selection_position(get_global_mouse_position())
	var selected_position = WorldTransformer.get_block_coordinate(real_mouse_position)
	debug_vflow_container.get_node("SelectedPosition").text = tr("selected_positionITION")+" : x="+str(selected_position[0])+", y="+str(-selected_position[1])
	var chunk_coordinate = WorldTransformer.get_chunk_coordinate(local_player_coordinate)
	debug_vflow_container.get_node("Chunk").text = tr("CHUNK")+" : x="+str(chunk_coordinate[0])+", y="+str(-chunk_coordinate[1])
	var fps = Engine.get_frames_per_second()
	debug_vflow_container.get_node("Fps").text = tr("FPS")+" : "+str(fps)
