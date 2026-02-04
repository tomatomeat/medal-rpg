extends Control
class_name MedalSlot

signal selected(medal)

var medal: MedalInstance
var disabled := false

@onready var button := $Button
@onready var medal_icon :MedalUI = $VisualRoot/CenterContainer/MedalUI

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func setup(m):
	medal = m
	$Name.text = MedalPresenter.get_display_name(medal)
	medal_icon.initialize(medal)

func _on_button_pressed():
	if disabled:
		return
	selected.emit(medal)
