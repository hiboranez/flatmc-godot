extends Button

@onready var animation_label = $AnimationLabel

var timer = 0

func _process(delta: float) -> void:
	if timer >= 0 and timer < 0.5:
		animation_label.text = "O o o"
	elif timer >= 0.5 and timer < 1:
		animation_label.text = "o O o"
	elif timer >= 1 and timer < 1.5:
		animation_label.text = "o o O"
	else:
		timer = 0
	timer += delta
