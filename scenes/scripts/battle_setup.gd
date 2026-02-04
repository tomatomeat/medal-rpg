extends Resource
class_name BattleSetup

signal context_ready(context: BattleContext)

func prepare(encounter_instance: EncounterInstance) -> void:
	var enemy_data: EnemyData = encounter_instance.enemy_data
	var encounter_party = encounter_instance.party
	
	var context := BattleContext.new()
	context.enemy_data = enemy_data
	context.p1_party = PartyManager.get_party_instances()
	context.p2_party = encounter_party
	
	emit_signal("context_ready", context)
