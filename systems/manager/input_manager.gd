extends Node

signal menu_pressed
signal cancel_pressed

var enabled := true

func _process(_delta):
	if not enabled:
		return

	if Input.is_action_just_pressed("menu"):
		emit_signal("menu_pressed")

	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("cancel_pressed")
