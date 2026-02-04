extends Control
class_name PartySlot

signal pressed(slot: PartySlot)
signal remove_requested(slot: PartySlot)

@export var index: int

@onready var button := $Panel/Button
@onready var name_label := $Panel/Name
@onready var medal_icon := $Panel/VisualRoot/CenterContainer/MedalUI
#@onready var remove_button := $RemoveButton # あれば

var medal: MedalInstance = null

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

	#if remove_button:
		#remove_button.pressed.connect(_on_remove_pressed)

func setup(m: MedalInstance) -> void:
	medal = m
	_update_view()

func clear() -> void:
	medal = null
	name_label.text = "-"
	medal_icon.clear()

func _update_view() -> void:
	if medal == null:
		clear()
		return
	
	name_label.text = MedalPresenter.get_display_name(medal)
	medal_icon.initialize(medal)

func _on_button_pressed() -> void:
	pressed.emit(self)

func _on_remove_pressed() -> void:
	remove_requested.emit(self)
