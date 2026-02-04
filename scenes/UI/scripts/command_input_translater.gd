extends Node
class_name BattleActionInputTranslator

var actor_id            # 今入力しているメダル / プレイヤー
var default_target_id   # 単体技用（必要なら）

func set_actor(id):
	actor_id = id

# --------------------
# Builders
# --------------------

func build_skill(skill_id: String):
	var battle_action := BattleAction.new()
	battle_action.type = BattleAction.ActionType.SKILL
	battle_action.actor_id = actor_id
	battle_action.skill_id = skill_id
	return battle_action

func build_rotation():
	var battle_action := BattleAction.new()
	battle_action.type = BattleAction.ActionType.ROTATION
	battle_action.actor_id = actor_id
	return battle_action

func build_surrender():
	var battle_action := BattleAction.new()
	battle_action.type = BattleAction.ActionType.SURRENDER
	battle_action.actor_id = actor_id
	return battle_action
