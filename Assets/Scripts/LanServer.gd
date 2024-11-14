extends Button

@onready var name_label = $Name
@onready var ip_label = $Ip

var ip
var port

func _on_focus_entered() -> void:
	StaticLoad.lan_server_ip = ip
	StaticLoad.lan_server_port = port
	StaticLoad.is_lan_server = true
