extends CanvasLayer

@onready var background = $Background
@onready var progress_bar = $Background/ProgressBar
@onready var loading_info = $Background/LoadingInfo

signal load_finished

var update_list: Array
var loaded_amount: int = 0
var prev_loaded_amount: int = 0
var total_amount: int = 0
var alpha: float = 0
var load_task_id: int = 0

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if background.modulate.a > alpha:
		background.modulate.a -= delta
		if background.modulate.a < alpha:
			background.modulate.a = alpha
	elif background.modulate.a < alpha:
		background.modulate.a += delta
		if background.modulate.a > alpha:
			background.modulate.a = alpha
	
	if background.modulate.a == 0:
		visible = false
		update_list.clear()
		WorkerThreadPool.wait_for_group_task_completion(load_task_id)
		set_process(false)
	
	if loaded_amount != prev_loaded_amount:
		prev_loaded_amount = loaded_amount
		if total_amount > 0:
			progress_bar.value = 100.0*loaded_amount/total_amount
	
	if loaded_amount == total_amount:
		load_finished.emit()
		alpha = 0

func update_resource(args: Array) -> void:
	alpha = 1
	visible = true
	for arg in args:
		match arg:
			Manager.TextureManage:
				total_amount += TextureManager.get_resource_amount()
			Manager.AudioManage:
				total_amount += AudioManager.get_resource_amount()
			Manager.SceneManage:
				total_amount += SceneManager.get_resource_amount()
			Manager.DataManage:
				total_amount += DataManager.get_resource_amount()
			Manager.SettingsManage:
				total_amount += SettingsManager.get_resource_amount()
	
	set_process(true)
	update_list = args.duplicate()
	load_task_id = WorkerThreadPool.add_group_task(load_resource, update_list.size())
	
func load_resource(index):
	match update_list[index]:
		Manager.TextureManage:
			TextureManager.update_resource()
		Manager.AudioManage:
			AudioManager.update_resource()
		Manager.SceneManage:
			SceneManager.update_resource()
		Manager.DataManage:
			DataManager.update_resource()
		Manager.SettingsManage:
			SettingsManager.update_resource()

func set_loading_info(text: String):
	loading_info.text = text

func add_loaded_amount():
	loaded_amount += 1
	
