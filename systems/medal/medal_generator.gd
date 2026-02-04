# medalGenerator.gd
class_name MedalGenerator

static func generate(medal_id: String) -> MedalInstance:
	var data: MedalData = MedalDataBase.get_medal(medal_id)
	if not data:
		push_error("medal data not found: " + medal_id)
		return null
	
	var save := MedalSaveData.new()
	
	save.medal_id = medal_id
	save.uuid = GenerateUUID.generate()
	save.current_health = data.base_hlt
	
	for t in InherentType.Type.values():
		if not save.inherent.has(t):
			save.inherent[t] = [0.8, 0.9, 1.0].pick_random()
	
	return MedalInstance.new(save)
