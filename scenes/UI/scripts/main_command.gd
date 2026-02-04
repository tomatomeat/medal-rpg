extends Control
class_name CommandUI

signal action_decided(action: BattleAction)
signal action_canceled

@onready var action_select := $ActionSelect
@onready var skill_select := $SkillSelect
@onready var rotation_ui := $Rotation

var current_user_id: String
var current_skills: Array

# ========================
# Entry
# ========================

func open_for_medal(medal:MedalState):
	current_user_id = medal.source.instance_id
	current_skills = medal.equipped_skill_ids

	_open_action_select()

func close_all():
	action_select.close()
	skill_select.close()
	rotation_ui.close()

# ========================
# ActionSelect
# ========================

func _open_action_select():
	close_all()
	action_select.open()

	action_select.skill_selected.connect(_on_skill_chosen, CONNECT_ONE_SHOT)
	action_select.rotation_selected.connect(_on_rotation_chosen, CONNECT_ONE_SHOT)

func _on_skill_chosen():
	action_select.close()
	_open_skill_select()

func _on_rotation_chosen():
	action_select.close()
	_open_rotation()

# ========================
# Skill
# ========================

func _open_skill_select():
	skill_select.open(current_skills)
	skill_select.skill_selected.connect(_on_skill_decided, CONNECT_ONE_SHOT)
	skill_select.canceled.connect(_open_action_select, CONNECT_ONE_SHOT)

func _on_skill_decided(skill_id: String):
	emit_signal("action_decided",BattleAction.ActionType.SKILL, skill_id)
	close_all()

# ========================
# Rotation
# ========================

func _open_rotation():
	rotation_ui.open()
	rotation_ui.confirmed.connect(_on_rotation_decided, CONNECT_ONE_SHOT)
	rotation_ui.canceled.connect(_open_action_select, CONNECT_ONE_SHOT)

func _on_rotation_decided():
	emit_signal("action_decided",BattleAction.ActionType.ROTATION)
	close_all()
