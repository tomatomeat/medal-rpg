extends Node

func generate() -> String:
	return "%08x-%04x-%04x-%04x-%012x" % [
		randi(), randi() & 0xffff,
		(randi() & 0x0fff) | 0x4000,
		(randi() & 0x3fff) | 0x8000,
		(randi() << 32) | randi()
	]
