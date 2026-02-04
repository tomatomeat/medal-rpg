class_name BattleAction
extends RefCounted

#入力アクション情報 どんな入力したか型

enum ActionType { SKILL, ROTATION, SURRENDER }
#入力情報
var type: ActionType           # "skill", "rotation", "surrender"
var action_id: String = ""  # 使う技やアイテム
var user_id: String        # 誰が行動するか
var target_ids: Array[String] = [] # 対象
var params: Dictionary = {}
