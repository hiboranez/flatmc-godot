class_name BlockLayer

enum {
	MIDDLE,
	BACK,
	FRONT,
	SUBSTANTIAL,
	INSUBSTANTIAL
}

static func get_name(enum_index: int) -> String:
	match enum_index:
		MIDDLE:
			return "solid"
		BACK:
			return "back"
		FRONT:
			return "front"
		_:
			return "unknown"

static func get_index(enum_name: String) -> int:
	match enum_name:
		"solid":
			return MIDDLE
		"back":
			return BACK
		"front":
			return FRONT
		_:
			return MIDDLE
