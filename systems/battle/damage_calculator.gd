class_name DamageCalculator
extends RefCounted

var stat_stage_multiplier = 1.1
var elements_multiplier = 1.3
var affinity_multiplier = 1.3

func calculate(dmg: DamageContext) -> int:
	
	var attacker = dmg.attacker
	var defender = dmg.defender
	var skill = dmg.skill
	
	var level = attacker.source.level
	var atk_stat: int = attacker.current_stat[skill.attack_reference_stat]
	var def_stat: int = defender.current_stat[skill.defense_reference_stat]
	var skill_power = dmg.base_power
	var atk_stat_stage_rate = dmg.atk_stat_stage_rate
	var def_stat_stage_rate = dmg.def_stat_stage_rate
	var element_rate = dmg.element_rate
	var affinity_rate = dmg.affinity_rate
	
	var damage: int = 1
	
	# Lv1: 1.0 / Lv50: 1.74 / Lv99: 2.47
	var level_factor: float = 1.0 + float(level - 1) * 0.015

	var base: float = (
		skill_power * level_factor * 1.1
		+ float(atk_stat - def_stat) * 0.25
		+ float(level) * 1.0
	)

	var stage_factor: float = atk_stat_stage_rate / def_stat_stage_rate
	var bonus_rate: float = 1.0 + element_rate + affinity_rate
	
	damage = int(floor(base * stage_factor * bonus_rate))

	return damage
