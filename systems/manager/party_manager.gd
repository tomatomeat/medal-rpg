extends Node

# パーティは instance_id だけを持つ
var party_ids: Array[String] = []

func _ready():
	pass

# --------------------
# 取得系
# --------------------

# UI / Battle 用：MedalInstance を返す
func get_party_instances() -> Array[MedalInstance]:
	var result: Array[MedalInstance] = []

	for instance_id in party_ids:
		var inst := MedalManager.get_medal(instance_id)
		if inst == null:
			continue
		result.append(inst)

	return result

# パーティの instance_id 配列
func get_party() -> Array[String]:
	return party_ids.duplicate()

func get_at(index: int) -> String:
	return party_ids[index] if index < party_ids.size() else ""

# --------------------
# 変更系
# --------------------

func add(instance_id: String) -> bool:
	if party_ids.size() >= 3:
		return false
	if instance_id in party_ids:
		return false

	party_ids.append(instance_id)
	return true

func remove_at(index: int):
	if index >= 0 and index < party_ids.size():
		party_ids.remove_at(index)

func set_at(index: int, instance_id: String) -> bool:
	if index < 0 or index >= 3:
		return false

	# すでに他枠にあったら除去（移動対応）
	party_ids.erase(instance_id)

	if index < party_ids.size():
		party_ids[index] = instance_id
	else:
		party_ids.append(instance_id)
	print(party_ids)
	return true

# --------------------
# セーブ / ロード
# --------------------

func confirm_party(new_party: Array[String]) -> void:
	party_ids = new_party.duplicate()
	SaveManager.save_all()

# SaveManager 用（uuid に変換）
func get_save_data() -> Array[String]:
	var result: Array[String] = []

	for instance_id in party_ids:
		var medal := MedalManager.get_medal(instance_id)
		if medal:
			result.append(medal.save.uuid)

	return result

func load_party(uuids: Array) -> void:
	party_ids.clear()

	for uuid in uuids:
		var medal := MedalManager.get_by_uuid(uuid)
		if medal:
			party_ids.append(medal.instance_id)
