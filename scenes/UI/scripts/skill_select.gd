extends Control
class_name SkillSelect

signal skill_selected(skill_id: String)
signal canceled

@onready var container := $VBoxContainer
@onready var back_button := $BackButton

var skills: Array = [] # Array[SkillData]

func _ready():
	back_button.pressed.connect(func(): emit_signal("canceled"))

func open(skill_list: Array):
	skills = skill_list
	visible = true
	_build_buttons()

func close():
	visible = false
	_clear_buttons()

func _build_buttons():
	_clear_buttons()
	for skill in skills:
		var btn := Button.new()
		btn.text = skill.name
		btn.disabled = not skill.can_use
		btn.pressed.connect(
			func():
				emit_signal("skill_selected", skill.id)
		)
		container.add_child(btn)

func _clear_buttons():
	for c in container.get_children():
		c.queue_free()
