class_name Chunk extends Node

static var para_list = [
	"entity_list", "dirt_list", "grass_block_list",
	"seed_list", "sapling_list", "leaves_list",
	"farm_land_list", "sugar_cane_list", "sign_dict"
]

var is_loaded: bool = false
var is_to_save: bool = false
var entity_list: Array = []
var dirt_list: Array = []
var grass_block_list: Array = []
var seed_list: Array = []
var sapling_list: Array = []
var leaves_list: Array = []
var farm_land_list: Array = []
var sugar_cane_list: Array = []
var sign_dict: Dictionary = {}
