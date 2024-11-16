extends TextureRect

# 自定义信号，可以接收一个字符串参数
@warning_ignore("unused_signal")
signal touch_button_focus_entered(node_name)

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	connect("touch_button_focus_entered", StaticLoad.game.touch_button)

func _touch_button_focus_entered() -> void:
	emit_signal("touch_button_focus_entered", self.name)
