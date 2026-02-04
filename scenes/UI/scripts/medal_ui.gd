extends Control
class_name MedalUI

@onready var icon: TextureRect = $background/icon
@onready var line: TextureRect = $background/line

var medal: MedalInstance

func initialize(m: MedalInstance) -> void:
	medal = m
	update_view()

func clear() -> void:
	medal = null
	icon.texture = null
	line.modulate = Color.WHITE

func update_view() -> void:
	if medal == null:
		clear()
		return

	icon.texture = medal.data.get_icon_texture()
	line.modulate = medal.data.secondary_color
