extends Node

var game: Node = null
var players: Node = null
var mobs: Node = null
var undead_mobs: Node = null
var local_player: Node = null
var background_layer: TileMapLayer = null
var substantial_layer: TileMapLayer = null
var insubstantial_layer: TileMapLayer = null
var chunk_dict: Dictionary
var connection_list = [
	"players", "mobs", "undead_mobs", "local_player", "game",
	"background_layer", "substantial_layer", "insubstantial_layer"
]

func update_connections(args: Dictionary) -> void:
	for connection_name in connection_list:
		if args.has(connection_name):
			set(connection_name, args[connection_name])

func check_connections() -> bool:
	for connection_name in connection_list:
		if get(connection_name) == null:
			return false
	return true

func clear_connections() -> void:
	for connection_name in connection_list:
		set(connection_name, null)
	chunk_dict.clear()
