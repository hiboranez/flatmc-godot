class_name GameMode

enum {
	SURVIVAL = 0,
	CREATIVE = 1
}

static func get_name(enum_index: int) -> String:
	match enum_index:
		SURVIVAL:
			return "survival"
		CREATIVE:
			return "creative"
		_:
			return "unknown"
