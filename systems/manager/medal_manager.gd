extends Node

# --------------------
# 内部管理
# --------------------

# uuid -> MedalInstance（保存・永続用）
var medals: Dictionary = {}

# instance_id -> uuid（高速参照用）
var uuid_by_instance: Dictionary = {}

# --------------------
# 生成
# --------------------

# 新規メダル生成（外部には instance_id を返す）
func create_medal(medal_id: String) -> String:
	var medal: MedalInstance = MedalGenerator.generate(medal_id)

	_register_medal(medal)

	SaveManager.save_all()
	return medal.instance_id

func _register_medal(medal: MedalInstance) -> void:
	medals[medal.uuid] = medal
	uuid_by_instance[medal.instance_id] = medal.uuid

# --------------------
# 取得系（外部向け）
# --------------------

# instance_id から MedalInstance 取得（基本これを使う）
func get_medal(instance_id: String) -> MedalInstance:
	var uuid :String = uuid_by_instance.get(instance_id)
	if uuid == null:
		return null
	return medals.get(uuid)

# uuid から取得（SaveManager / 内部用）
func get_by_uuid(uuid: String) -> MedalInstance:
	var medal: MedalInstance = medals.get(uuid)
	if medal == null:
		push_warning("Medal not found for uuid: " + uuid)
	return medal

func get_medal_save_by_instance_id(instance_id: String) -> MedalSaveData:
	var medal := get_medal(instance_id)
	return medal.save if medal else null

func get_all_instances() -> Array[MedalInstance]:
	var result: Array[MedalInstance] = []
	for medal in medals.values():
		result.append(medal)
	return result

# --------------------
# Buddy 管理（instance_id 基準）
# --------------------

func set_buddy(instance_id: String):
	for medal in medals.values():
		medal.is_Buddy = false

	var medal := get_medal(instance_id)
	if medal:
		medal.is_Buddy = true

# --------------------
# セーブ / ロード
# --------------------

# SaveManager 用（uuid -> dict）
func get_save_data() -> Dictionary:
	var result := {}
	for uuid in medals:
		result[uuid] = medals[uuid].to_dict()
	return result

func load_medals(medals_dict: Dictionary) -> void:
	medals.clear()
	uuid_by_instance.clear()

	for uuid in medals_dict.keys():
		var medal_data: Dictionary = medals_dict[uuid]
		var medal := MedalInstance.from_dict(medal_data)

		if medal == null:
			push_error("Failed to load medal: " + str(uuid))
			continue

		medals[uuid] = medal
		uuid_by_instance[medal.instance_id] = uuid
