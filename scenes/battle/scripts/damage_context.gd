class_name DamageContext
extends RefCounted

var attacker: MedalState
var defender: MedalState
var skill: SkillData

var base_power: int

var stat_bonus: int = 0
var atk_stat_stage_rate: float = 1.0
var def_stat_stage_rate: float = 1.0
var element_rate: float = 1.0
var affinity_rate: float = 1.0
var total_damage: int = 0
var cancelled: bool = false
