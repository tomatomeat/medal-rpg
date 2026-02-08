extends Node

# ===== 設定値 =====
@export var threshold := 100.0
@export var base_chance := 1.0
@export var cooldown_time := 1.0

# ===== 状態 =====
var gauge := 0.0
var cooldown := 0.0

var encounter_enabled := true
var current_area_id := ""
var danger_level := 1

var active_zone: EncounterZone = null

# Player から呼ばれる
func on_player_moved(distance: float, delta: float) -> void:
	# エリア全体で無効
	if not encounter_enabled:
		return

	# ゾーン外では完全に何もしない
	if active_zone == null:
		return

	# ゾーンが無効
	if not active_zone.enabled:
		return

	# クールダウン中
	if cooldown > 0:
		return
	
	gauge += distance
	print(gauge)

	if gauge >= threshold:
		try_encounter()

# エンカウント抽選
func try_encounter() -> void:
	# ゾーンがない / 無効なら中止
	if active_zone == null or not active_zone.enabled:
		return
	
	gauge = 0.0
	cooldown = cooldown_time

	start_battle()

# 戦闘開始
func start_battle() -> void:
	print("Encounter! area = ", current_area_id)
	
	var zone_data := active_zone.data
	var medal_pool : EncountMedalPool = zone_data.medal_pool
	var encounter_pool := zone_data.encounter_pool
	
	#Enemy抽選
	if encounter_pool.is_empty():
		push_error("Encounter pool is empty")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var enemy_id: String = encounter_pool[rng.randi_range(0, encounter_pool.size() - 1)]
	
	var enemy_data := EnemyDataBase.get_enemy(enemy_id)
	if enemy_data == null:
		push_error("Enemy not found: " + enemy_id)
		return
		
	var partybuild := PartyBuilder.new()
	var party = partybuild.build_party(zone_data,medal_pool)
	
	var instance := EncounterInstance.new()
	instance.party = party
	instance.intelligence = 1
	
	BattleDirector.request_battle(instance)

# フレーム更新
func _process(delta: float) -> void:
	if cooldown > 0:
		cooldown = max(cooldown - delta, 0)

# エリア制御（FieldController から呼ぶ）
func set_area(area_id: String, enable: bool) -> void:
	current_area_id = area_id
	encounter_enabled = enable

	# エリア切替時は必ずリセット
	gauge = 0.0
	cooldown = 0.0
	active_zone = null

# Zone 制御（EncounterZone から呼ぶ）
func on_zone_enter(zone: EncounterZone) -> void:
	if not encounter_enabled:
		return

	if zone.enabled:
		active_zone = zone
		# gauge = 0.0  # 入った瞬間リセット（重要） # じゃない

func on_zone_exit(zone: EncounterZone) -> void:
	if active_zone == zone:
		active_zone = null
		#gauge = 0.0  # 出たら完全リセット # しない
