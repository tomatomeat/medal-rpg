# res://battle/BattleRules.gd
class_name BattleUtil

static func is_ally(a: MedalState, b: MedalState) -> bool:
	return a.side == b.side

static func is_opponent(a: MedalState, b: MedalState) -> bool:
	return a.side != b.side
