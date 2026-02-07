extends Resource
class_name BattleSetup

signal context_ready(context: BattleContext)

func prepare(encounter_instance: EncounterInstance) -> void:
	var enemy_data: EnemyData = encounter_instance.enemy_data
	var encounter_party = encounter_instance.party
	
	var p1_party_instance = PartyManager.get_party_instances()
	var p2_party_instance = encounter_party
	
	var p1_party = []
	var p2_party = []
	
	for m in p1_party_instance:
		var ms := m.create_medal_state()
		ms.side = MedalState.Side.P1
		p1_party.append(ms)
	
	for m in p2_party_instance:
		var ms := m.create_medal_state()
		ms.side = MedalState.Side.P2
		p2_party.append(ms)
		
	var context := BattleContext.new()
	context.enemy_data = enemy_data
	context.p1_party = p1_party
	context.p2_party = p2_party
	
	emit_signal("context_ready", context)
