extends RefCounted
class_name MedalState

#バトル中のメダル可変情報

enum Side {
	P1,
	P2
}
var side

var source: MedalInstance

var hp: int
var stat_stage: Dictionary = {}
var actual_stat: Dictionary = {}
var current_stat: Dictionary = {}
var status_effect_id: String
var elements: Array[Elements]
var effectiveness_elements: Array[Elements]
var weakness_affinity: Array[Affinity]
var ability_id: String
var stat_stage_upper: int = 10
var stat_stage_lower: int = 10
var equipped_skill_ids: Array[String] = []
var tags: Dictionary
