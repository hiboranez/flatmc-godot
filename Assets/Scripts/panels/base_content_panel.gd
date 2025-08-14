extends Control

@onready var title_label = $Title
@onready var content_rect = $Content

@export var title: String = ""
@export var content_top_margin: float = 160
@export var content_bottom_margin: float = 160

var menu: Menu = null
var animating_panel: Node = null

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)

func animated_refresh_size(panel: Node):
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	title_label.scale = Vector2(menu.scale_factor, menu.scale_factor)
	title_label.text = tr(title)
	title_label.pivot_offset.x = canvas_size.x/2
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	animating_panel = panel
	tween.tween_property(content_rect, "size", Vector2(content_rect.size.x, canvas_size.y-(content_top_margin+content_bottom_margin)*menu.scale_factor), menu.menu_controller.animation_time)
	tween.parallel().tween_property(title_label, "position", Vector2(position.x, ((content_top_margin-title_label.size.y)*menu.scale_factor)/2), menu.menu_controller.animation_time)
	tween.parallel().tween_property(content_rect, "position", Vector2(position.x, content_top_margin*menu.scale_factor), menu.menu_controller.animation_time)
	tween.parallel().tween_method(animated_refresh_panel_size, 0, 1, menu.menu_controller.animation_time)
	await tween.finished
	
func animated_refresh_panel_size(value):
	animating_panel.refresh_size()

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	title_label.scale = Vector2(menu.scale_factor, menu.scale_factor)
	content_rect.set_deferred("size", Vector2(content_rect.size.x, canvas_size.y-(content_top_margin+content_bottom_margin)*menu.scale_factor))
	title_label.text = tr(title)
	title_label.pivot_offset.x = canvas_size.x/2
	title_label.position.y = ((content_top_margin-title_label.size.y)*menu.scale_factor)/2
	content_rect.position.y = content_top_margin*menu.scale_factor

func set_content(content: Node):
	content_rect.add_child(content)
