extends Node

signal log_message(message: String)
signal animation_requested(anim_data: Dictionary)

signal request_place_medals(placements)

var manager: BattleManager
var setup: BattleSetup

var _context_ready := false
var _scene_ready := false

# UI参照（Battleシーンでセット）
@export var command_ui: CommandUI
#@export var status_ui

# ========================
# Battle Start
# ========================

func request_battle(encounter_instance: EncounterInstance):
	var party = PartyManager.get_party_instances()
	var encounter_party = encounter_instance.party
	
	if party.is_empty():
		push_warning("Battle start failed: party is empty")
		return false
	
	if encounter_party.is_empty():
		push_warning("Battle start failed: encounter's party is empty")
		return false
	
	_start_setup(encounter_instance)

func _start_setup(encounter_instance: EncounterInstance):
	setup = BattleSetup.new()
	setup.context_ready.connect(_on_context_ready)
	setup.prepare(encounter_instance)

func _on_context_ready(context: BattleContext):
	manager = BattleManager.new()
	manager.bind(context)

	manager.action_resolved.connect(_on_action_resolved)
	manager.turn_ended.connect(_on_turn_ended)
	
	_context_ready = true
	SceneManager.change_scene(SceneID.BATTLE)
	_try_start_battle()

func on_battle_scene_ready():
	_scene_ready = true
	_try_start_battle()

func _try_start_battle():
	if not _context_ready:
		return
	if not _scene_ready:
		return

	_start_battle()

func _start_battle():
	_open_command_for_current_actor()

# ========================
# UI → Director
# ========================

func on_action_confirm(action_type: BattleAction.ActionType,action_id: String):
	var user_id := manager.p1_active_medal_id # 今は仮でP1
	var action := BattleAction.new()
	action.type = action_type
	action.user_id = user_id
	action.action_id = action_id

	manager.request_action(action)
	command_ui.close()

func on_command_canceled():
	command_ui.open_main()

# ========================
# Manager → Director
# ========================

func _on_action_resolved(result: ActionResult):
	# UI用に翻訳
	emit_signal("animation_requested", result.to_anim_data())
	emit_signal("log_message", result.to_log())

func _on_turn_ended(turn_number: int):
	_refresh_ui()
	manager.start_turn()
	_open_command_for_current_actor()

# ========================
# UI Control
# ========================

func _open_command_for_current_actor():
	var medal: MedalState = manager.state.medal_map.get(manager.p1_active_medal_id)
	if medal == null:
		return

	command_ui.open_for_medal(medal)

func _refresh_ui():
	var medal: MedalState = manager.state.medal_map[manager.p1_active_medal_id]
	#status_ui.update_status(medal.to_ui_data())

func place_medals():
	var p1_party = manager.state.p1_party
	var p2_party = manager.state.p2_party
	var placements := {
		p1 = p1_party,
		p2 = p2_party
	}
	emit_signal("request_place_medals", placements)
