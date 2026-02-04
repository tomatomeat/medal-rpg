extends Control
class_name RotationUI

signal confirmed
signal canceled

@onready var yes_btn := $Yes
@onready var no_btn := $No

func _ready():
	yes_btn.pressed.connect(func(): emit_signal("confirmed"))
	no_btn.pressed.connect(func(): emit_signal("canceled"))

func open():
	visible = true

func close():
	visible = false
