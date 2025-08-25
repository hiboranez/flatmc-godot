extends Control

@onready var selected_rect = $Selected
@onready var unselected_rect = $MarginContainer/Unselected
@onready var item_icon = $ItemIcon

@export var index: int = 0
@export var vertical_location: String = "top"
@export var horizonal_location: String = "middle"
var panel: Node = null

func _ready() -> void:
	selected_rect.texture = TextureManager.get_texture("ui/tab_"+vertical_location+"_"+horizonal_location+"_selected")

func update_data(args: Dictionary) -> void:
	if args.has("icon_name") and args["icon_name"] is String:
		item_icon.init_icon(args["icon_name"])
		item_icon.visible = true
	if args.has("panel") and args["panel"] is Node:
		panel = args["panel"]

func clear_selection() -> void:
	panel.visible = false
	selected_rect.visible = false

func _on_unselected_gui_input(event: InputEvent) -> void:
	ActionManager.execute_action("inventory_creative_ui", "clear_selection")
	panel.visible = true
	selected_rect.visible = true
