extends TextureRect

# 自定义信号，可以接收一个字符串参数
@warning_ignore("unused_signal")
signal item_grid_focus_entered(node_name)

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	connect("item_grid_focus_entered", StaticLoad.game.select_item_grid)

func _on_item_bar_focus_entered() -> void:
	emit_signal("item_grid_focus_entered", self.name)
