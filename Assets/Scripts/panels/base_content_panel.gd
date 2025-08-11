extends Control

@onready var title_label = $Title
@onready var content_rect = $Content

@export var title: String = ""
@export var content_top_margin: float = 160
@export var content_bottom_margin: float = 160

func _ready() -> void:
	title_label.text = str(title)
	title_label.position.y = (content_top_margin-title_label.size.y)/2
	content_rect.position.y = content_top_margin
	var canvas_height = (get_global_transform_with_canvas().affine_inverse()*get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)).y
	content_rect.set_deferred("size", Vector2(content_rect.size.x, canvas_height-content_top_margin-content_bottom_margin))

func set_content(content: Node):
	content_rect.add_child(content)
