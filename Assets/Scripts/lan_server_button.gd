extends Control

@onready var selected_background = $SelectedBackground
@onready var name_label = $Name
@onready var ip_label = $Ip

signal pressed

var server_name: String = ""
var server_type: String = "lan"
var server_ip: String = ""
var server_port: int = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			pressed.emit()
	elif event is InputEventScreenTouch:
		if event.pressed:
			pressed.emit()

func init(args: Dictionary) -> void:
	update_info(args)
	if server_port != -1:
		name_label.text = server_name
		ip_label.text = server_ip+":"+str(server_port)
	else:
		name_label.text = tr("ERROR")
		ip_label.text = ""

func update_info(args: Dictionary):
	if args.has("server_ip") and args["server_ip"] is String:
		server_ip = args["server_ip"]
	if args.has("server_port") and args["server_port"] is int:
		server_port = args["server_port"]
	if args.has("server_name") and args["server_name"] is String:
		server_name = args["server_name"]

func set_selected_background_visible(got_visible: bool) -> void:
	selected_background.visible = got_visible

func _on_button_pressed() -> void:
	ServerManager.update_data({
		"server_name": server_name,
		"server_type": server_type, 
		"server_ip": server_ip,
		"server_port": server_port
	})
