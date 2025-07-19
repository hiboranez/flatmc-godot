extends Label

const slogan_num:int = 4

func _ready():
	text = "SLOGAN_" + str(randi_range(1,slogan_num))
	# 立即在节点加载时执行动画
	start_font_animation()

func start_font_animation():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	# 阶段1: 从40平滑增大到45，持续0.5秒
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self.label_settings, "font_size", 50, 0.25)
	
	# 阶段2: 从45平滑减小到40，持续0.5秒
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self.label_settings, "font_size", 40, 0.25)
	
	# 结束后重复动画
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished():
	# 动画完成后重新开始
	start_font_animation()
