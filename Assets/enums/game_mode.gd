class_name GameMode

enum {
	SURVIVAL = 0,
	CREATIVE = 1
}

static func get_name(enum_sort):
	match enum_sort:
		SURVIVAL:
			return "survival"
		CREATIVE:
			return "creative"
		_:
			return "unknown"
