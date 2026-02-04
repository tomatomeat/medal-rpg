extends Control
class_name ActionSelect

signal skill_selected
signal rotation_selected

@onready var skill_btn := $VBoxContainer/Skill
@onready var rotation_btn := $VBoxContainer/Rotation

func _ready():
	skill_btn.pressed.connect(_on_skill_pressed)
	rotation_btn.pressed.connect(_on_rotation_pressed)

func open():
	visible = true

func close():
	visible = false

func _on_skill_pressed() -> void:
	emit_signal("skill_selected")

func _on_rotation_pressed() -> void:
	emit_signal("rotation_selected")
