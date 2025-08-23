extends CanvasLayer

@onready var background_rect = $Background
@onready var player_model = $Panel/InventoryPanel/Player/Frame/SubViewportContainer/SubViewport/PlayerModel
@onready var player_mesh = $Panel/InventoryPanel/Player/Frame/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var handheld_item = $Panel/InventoryPanel/Player/Frame/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Hand/Item
@onready var tab_panels = $Panel/TabPanels

func _ready() -> void:
	for tab_name in StaticLoad.tab_panels:
		var tab_panel = SceneManager.get_scene("others/tab_panel").instantiate()
		tab_panels.add_child(tab_panel)
		tab_panel.name = tab_name+"Tab"
		tab_panel.init_tab_panel(StaticLoad.tab_panels[tab_name], tab_name, tab_panels)
		if tab_name == "Inventory":
			tab_panel.z_index = 1
			tab_panel.dark_mask.visible = false
	ActionManager.register_action("inventory_ui", "set_mesh_surface_material", set_mesh_surface_material)
	ActionManager.register_action("inventory_ui", "update_handheld_item_visible", update_handheld_item_visible)

func _process(delta: float) -> void:
	var mouse_position = InputManager.get_mouse_position()
	var viewport_size = background_rect.get_viewport_rect().size
	var viewport_half_size = viewport_size/2.0
	var target_pos = mouse_position-viewport_half_size+Vector2(viewport_size[0]*0.112,viewport_size[1]*0.25)
	player_model.look_at(Vector3(target_pos[0], -target_pos[1], 3250), Vector3.UP, true)

func set_mesh_surface_material(args: Dictionary) -> void:
	var surface_material = args["surface_material"]
	if args["mesh"] == "player":
		player_mesh.mesh.surface_set_material(0, surface_material)
	elif args["mesh"] == "tool":
		handheld_item.get_node("Tool/Mesh").mesh.surface_set_material(0, surface_material)
	elif args["mesh"] == "block":
		handheld_item.get_node("Block/Mesh").mesh.surface_set_material(0, surface_material)
	elif args["mesh"] == "item":
		handheld_item.get_node("Item/Mesh").mesh.surface_set_material(0, surface_material)

func update_handheld_item_visible(args: Dictionary) -> void:
	for node_name in args:
		handheld_item.get_node(node_name).visible = args[node_name]
