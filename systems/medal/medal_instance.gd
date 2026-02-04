extends RefCounted
class_name MedalInstance

const EC_MAX := 100
const TOTAL_EC_MAX := 300

# ===== 不変ID =====
var data: MedalData
var save: MedalSaveData
var instance_id: String
var uuid: String

# ===== 可変セーブデータ =====
var level := 0
var nickname: String = ""
var current_health: int
var title_id: String = ""
var ruin_id: String = ""
var ruin_params: Dictionary = {}
var ec := {} # StatType.Type -> int
var actual_stat := {}
var cost := 0
var skill_slot := 4
var stat_stage_upper := 10
var stat_stage_lower := 10
var weakness_affinity := []
var ability_id := ""
var inherent := {}

var learned_skill_ids: Array[String] = []
var equipped_skill_ids: Array[String] = []

# ===== 初期化 =====
func _init(_save: MedalSaveData) -> void:
	save = _save
	save.ensure_ec_initialized()
	save.ensure_inherent_initialized()
	
	data = MedalDataBase.get_medal(save.medal_id)
	if data == null:
		push_error("medalData not found: " + save.medal_id)
	
	instance_id = GenerateUUID.generate()
	uuid = save.uuid
	
	for stat in StatType.Type.values():
		ec[stat] = save.ec[stat]
	
	nickname = save.nickname
	
	ability_id = save.ability_id
	
	title_id = save.title_id
	ruin_id = save.ruin.ruin_id
	ruin_params = save.ruin.params
	
	learned_skill_ids = save.learned_skill_ids
	equipped_skill_ids = save.equipped_skill_ids
	
	cost = get_cost()
	level = save.level
	
	stat_stage_upper = get_stat_stage_upper()
	stat_stage_lower = get_stat_stage_lower()
	
	weakness_affinity = get_weakness_affinity()
	
	inherent = save.inherent
	
	current_health = get_hlt()
	
	update_actual_stat()

func create_medal_state() -> MedalState:
	var s := MedalState.new()
	s.source = self

	s.hp = current_health
	
	for stat in StatType.Type.values():
		s.actual_stat[stat] = get_actual(stat)

	s.stat_stage = {}
	for stat in StatType.Type.values():
		s.stat_stage[stat] = 0

	s.stat_stage_upper = stat_stage_upper
	s.stat_stage_lower = stat_stage_lower

	s.status_effect_id = ""
	s.tags = {}

	s.elements = data.elements
	s.effectiveness_elements = []

	s.weakness_affinity = get_weakness_affinity().duplicate()

	s.ability_id = ability_id

	s.equipped_skill_ids = equipped_skill_ids.duplicate()

	return s


# ===== DB参照（getter） =====
func get_title() -> TitleData:
	if title_id == "":
		return null
	return TitleDataBase.get_title(title_id)

func get_actual(_stat:StatType.Type) -> int:
	update_actual_stat()
	return actual_stat[_stat]

func get_learned_skills() -> Array[SkillData]:
	return learned_skill_ids.map(func(id): return SkillDataBase.get_skill(id))

func get_equipped_skills() -> Array[SkillData]:
	return equipped_skill_ids.map(func(id): return SkillDataBase.get_skill(id))

# ===== ステータス計算 =====
func update_actual_stat() -> void:
	for stat in StatType.Type.values():
		actual_stat[stat] = get_total_stat(stat)

func _bonus_stat_key(stat: StatType.Type):
	var key: String
	match stat:
		StatType.Type.HLT:
			key = "bonus_hlt"
		StatType.Type.SLH:
			key = "bonus_slh"
		StatType.Type.BLT:
			key = "bonus_blt"
		StatType.Type.ALT:
			key = "bonus_alt"
		StatType.Type.SLR:
			key = "bonus_slr"
		StatType.Type.BLR:
			key = "bonus_blr"
		StatType.Type.ALR:
			key = "bonus_alr"
		StatType.Type.SPD:
			key = "bonus_spd"
	return key

func _bonus(stat: StatType.Type) -> int:
	var t := get_title()
	if t == null:
		return 0
	var key = _bonus_stat_key(stat)
	# TitleDataにそのプロパティがあるかチェック
	if not t.has_property(key):
		return 0
	print("TitleBonus: ",t.get(key))
	return int(t.get(key))

func _get_inherent(stat: StatType.Type) -> float:
	var value: float = 0.0
	match stat:
		StatType.Type.SLH:
			value = inherent[InherentType.Type.ATK]
		StatType.Type.BLT:
			value = inherent[InherentType.Type.ATK]
		StatType.Type.ALT:
			value = inherent[InherentType.Type.ATK]
		StatType.Type.SLR:
			value = inherent[InherentType.Type.DEF]
		StatType.Type.BLR:
			value = inherent[InherentType.Type.DEF]
		StatType.Type.ALR:
			value = inherent[InherentType.Type.DEF]
		StatType.Type.HLT:
			value = inherent[InherentType.Type.HP]
		StatType.Type.SPD:
			value = inherent[InherentType.Type.SPD]
	
	return value

func _get_stat(
	base: int,
	_inherent: float,
	stat: StatType.Type,
	bonus: int
) -> int:
	return int(
		((((base * 2) * _inherent) * 2 + ec[stat])
		* ((level + 15) / 40.0))
		+ bonus
	)

func opposite_stat(_stat: StatType.Type) -> int:
	var stat:StatType.Type
	match _stat:
		StatType.Type.SLH:
			stat = StatType.Type.SLR
		StatType.Type.BLT:
			stat = StatType.Type.BLR
		StatType.Type.ALT:
			stat = StatType.Type.ALR
		StatType.Type.SLR:
			stat = StatType.Type.SLH
		StatType.Type.BLR:
			stat = StatType.Type.BLT
		StatType.Type.ALR:
			stat = StatType.Type.ALT
	return stat

func get_total_stat(_stat: StatType.Type) -> int:
	var stat:int
	match _stat:
		StatType.Type.SLH:
			stat = get_slh()
		StatType.Type.BLT:
			stat = get_blt()
		StatType.Type.ALT:
			stat = get_alt()
		StatType.Type.SLR:
			stat = get_slr()
		StatType.Type.BLR:
			stat = get_blr()
		StatType.Type.ALR:
			stat = get_alr()
		StatType.Type.HLT:
			stat = get_hlt()
		StatType.Type.SPD:
			stat = get_speed()
	return stat

func get_slh() -> int:
	var _stat = StatType.Type.SLH
	return _get_stat(data.base_slh, _get_inherent(_stat), _stat, _bonus(_stat))

func get_blt() -> int:
	var _stat = StatType.Type.BLT
	return _get_stat(data.base_blt, _get_inherent(_stat), _stat, _bonus(_stat))

func get_alt() -> int:
	var _stat = StatType.Type.ALT
	return _get_stat(data.base_alt, _get_inherent(_stat), _stat, _bonus(_stat))

func get_slr() -> int:
	var _stat = StatType.Type.SLR
	return _get_stat(data.base_slr, _get_inherent(_stat), _stat, _bonus(_stat))

func get_blr() -> int:
	var _stat = StatType.Type.BLR
	return _get_stat(data.base_blr, _get_inherent(_stat), _stat, _bonus(_stat))

func get_alr() -> int:
	var _stat = StatType.Type.ALR
	return _get_stat(data.base_alr, _get_inherent(_stat), _stat, _bonus(_stat))

func get_hlt() -> int:
	var _stat = StatType.Type.HLT
	return _get_stat(data.base_hlt, _get_inherent(_stat), _stat, _bonus(_stat))

func get_speed() -> int:
	var _stat = StatType.Type.SPD
	return _get_stat(data.base_spd, _get_inherent(_stat), _stat, _bonus(_stat))

func get_cost() -> int:
	if ruin_id != "":
		pass
	return data.control_cost

func get_skill_slot() -> int:
	if ruin_id != "":
		return 4
	else:
		return 4
	
func get_stat_stage_upper() -> int:
	if ruin_id != "":
		return 10
	else:
		return 10

func get_stat_stage_lower() -> int:
	if ruin_id != "":
		return 10
	else:
		return 10

func get_weakness_affinity() -> Array[Affinity]:
	if ruin_id != "":
		return data.weakness_affinity
	else:
		return data.weakness_affinity

# ===== HP操作 =====
func is_dead() -> bool:
	return current_health <= 0

# ===== EC操作 =====
func change_ec(stat: StatType.Type, delta: int) -> bool:
	var next: int = int(ec[stat]) + delta
	if next < 0 or next > EC_MAX:
		return false
	ec[stat] = next
	_clamp_health()
	return true

func _clamp_health() -> void:
	current_health = clamp(current_health, 0, get_hlt())

# ===== スキル管理 =====
func learn_skill(skill_id: String) -> bool:
	if learned_skill_ids.has(skill_id):
		return false
	learned_skill_ids.append(skill_id)
	return true

func equip_skill(skill_id: String) -> bool:
	if !learned_skill_ids.has(skill_id):
		return false
	if equipped_skill_ids.has(skill_id):
		return false
	if equipped_skill_ids.size() >= data.max_equipped_skills:
		return false
	equipped_skill_ids.append(skill_id)
	return true

func unequip_skill(skill_id: String) -> bool:
	if not equipped_skill_ids.has(skill_id):
		return false
	equipped_skill_ids.erase(skill_id)
	return true

# ===== セーブ / ネットワーク =====
func to_dict() -> Dictionary:
	return {
		"nickname": nickname,
		"medal_id": data.medal_id,
		"uuid": save.uuid,
		"title_id": title_id,
		"ruin_id": ruin_id,
		"ruin_params": ruin_params.duplicate(),
		"ec": ec.duplicate(),
		"learned_skill_ids": learned_skill_ids.duplicate(),
		"equipped_skill_ids": equipped_skill_ids.duplicate()
	}

static func from_dict(dict: Dictionary) -> MedalInstance:
	# --- medalData取得 ---
	if not dict.has("medal_id"):
		push_error("from_dict: missing medal_id")
		return null

	var medal_data: MedalData = MedalDataBase.get_medal(dict["medal_id"])
	if medal_data == null:
		push_error("medalData not found: " + str(dict["medal_id"]))
		return null

	# --- SaveData ---
	var save_data := MedalSaveData.new()
	save_data.medal_id = dict["medal_id"]
	save_data.uuid = dict.get("uuid", "")

	var inst := MedalInstance.new(save_data)

	# --- HP ---
	inst.current_health = int(dict.get("current_health", inst.get_actual(StatType.Type.HLT)))

	# --- Title ---
	inst.title_id = str(dict.get("title_id", ""))
	# --- Ruin ---
	inst.ruin_id = str(dict.get("ruin_id", ""))
	inst.ruin_params = dict.get("ruin_params", {})

	# --- EC（欠損耐性あり） ---
	var dict_ec: Dictionary = dict.get("ec", {})
	for stat in StatType.Type.values():
		inst.ec[stat] = int(dict_ec.get(stat, 0))

	# --- Learned Skills ---
	inst.learned_skill_ids.clear()
	if dict.has("learned_skill_ids") and dict["learned_skill_ids"] is Array:
		for id in dict["learned_skill_ids"]:
			if id is String:
				inst.learned_skill_ids.append(id)

	# --- Equipped Skills ---
	inst.equipped_skill_ids.clear()
	if dict.has("equipped_skill_ids") and dict["equipped_skill_ids"] is Array:
		for id in dict["equipped_skill_ids"]:
			if id is String:
				inst.equipped_skill_ids.append(id)

	# --- 最終補正 ---
	inst._clamp_health()

	return inst

# ===== 軽量同期 =====
func to_dict_light() -> Dictionary:
	return {
		"uuid": save.uuid,
		"current_health": current_health,
		"ec": ec.duplicate()
	}

func update_from_dict_light(dict: Dictionary) -> void:
	if dict["uuid"] != save.uuid:
		push_error("UUID mismatch")
		return
	current_health = dict["current_health"]
	ec = dict["ec"].duplicate()
	_clamp_health()
