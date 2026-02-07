extends Control

var medals: Array = []
var selected_medal_id: String = ""
var temp_party: Array[String] = []

var return_scene_id: int

@onready var vbox_container := $VBoxContainer
@onready var list_container := $Scroll/MarginContainer/Grid
@onready var medal_slot_scene := preload("res://scenes/UI/medal_slot.tscn")
@onready var confirm_button := $ConfirmButton
@onready var back_button := $BackButton

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	back_button.pressed.connect(_on_cancel_pressed)
	for slot in vbox_container.get_children():
		slot.pressed.connect(_on_party_slot_pressed)
		slot.remove_requested.connect(_on_party_remove)
	open()

# --------------------
# Open / Confirm
# --------------------

func open():
	return_scene_id = SceneManager.previous_scene_id
	visible = true
	temp_party = PartyManager.get_party().duplicate()
	_refresh_medals()
	_build_party()
	_build_list()

func _on_confirm_pressed():
	PartyManager.confirm_party(temp_party)
	close()

func _on_cancel_pressed():
	close()
	
# --------------------
# Medal List
# --------------------

func _refresh_medals():
	medals = MedalManager.get_all_instances()

func _build_list():
	_clear_list()

	for medal in medals:
		var slot: MedalSlot = medal_slot_scene.instantiate()

		# 仮パーティに入ってたら無効
		if medal.instance_id in temp_party:
			slot.disabled = true

		list_container.add_child(slot)
		slot.selected.connect(_on_medal_selected)
		slot.setup(medal)

func _clear_list():
	for c in list_container.get_children():
		c.queue_free()

func close():
	selected_medal_id = ""
	temp_party.clear()
	
	SceneManager.change_scene(return_scene_id,{"Position":Vector2.ZERO})

# --------------------
# Party Slots（仮パーティ）
# --------------------

func _build_party():
	for i in range(3):
		var slot: PartySlot = vbox_container.get_child(i)

		if i < temp_party.size():
			var medal := MedalManager.get_medal(temp_party[i])
			slot.setup(medal)
		else:
			slot.clear()

# --------------------
# Callbacks
# --------------------

func _on_medal_selected(medal):
	selected_medal_id = medal.instance_id

func _on_party_slot_pressed(slot: PartySlot):
	if selected_medal_id == "":
		return

	# 同じメダルなら無視
	if slot.index < temp_party.size() and temp_party[slot.index] == selected_medal_id:
		return

	# すでに別枠にあったら削除（スワップ対応）
	temp_party.erase(selected_medal_id)

	# セット
	if slot.index < temp_party.size():
		temp_party[slot.index] = selected_medal_id
	else:
		temp_party.append(selected_medal_id)

	selected_medal_id = ""
	_build_party()
	_build_list()

func _on_party_remove(slot: PartySlot):
	if slot.index >= 0 and slot.index < temp_party.size():
		temp_party.remove_at(slot.index)
	_build_party()
	_build_list()
