class_name BattleState
extends RefCounted

var current_turn: int

var p1_party: Array[MedalInstance] = []
var p2_party: Array[MedalInstance] = []

var medal_map: Dictionary = {} # instance_id -> MedalInstance
