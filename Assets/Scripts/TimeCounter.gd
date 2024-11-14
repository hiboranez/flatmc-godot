extends Node2D

var timer = 0

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	timer += delta

func start_counting():
	set_process(true)

func stop_counting():
	set_process(false)
