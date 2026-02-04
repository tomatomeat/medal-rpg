extends Node
class_name PartyBuilder

# メインAPI
const PARTY_SIZE := 3

func build_party(zone: EncounterZoneData, pool: EncountMedalPool) -> Array[MedalInstance]:
	var result: Array[MedalInstance] = []

	if pool == null or pool.entries.is_empty():
		return result

	# 抽選用コピー（参照を壊さない）
	var remaining: Array[EncountMedalPoolEntry] = pool.entries.duplicate()

	while result.size() < PARTY_SIZE and not remaining.is_empty():
		var entry := _weighted_pick_entry(remaining)
		remaining.erase(entry)
		
		var medal_id := entry.medal_id
		if medal_id == "":
			continue

		var data := MedalDataBase.get_medal(medal_id)
		if data == null:
			push_warning("Medal not found: " + medal_id)
			continue
		
		var instance := MedalGenerator.generate(medal_id)
		
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		
		instance.level = zone.base_level + rng.randi_range(-6, 6)
		
		result.append(instance)
	
	return result

func _weighted_pick_entry(list: Array[EncountMedalPoolEntry]) -> EncountMedalPoolEntry:
	var total := 0
	for e in list:
		total += max(e.weight, 0)

	if total <= 0:
		return list.pick_random()

	var r := randi() % total
	var acc := 0

	for e in list:
		acc += max(e.weight, 0)
		if r < acc:
			return e

	return list.back()
