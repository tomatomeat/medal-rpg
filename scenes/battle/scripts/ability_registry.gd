extends Object
class_name AbilityRegistry

static var _ability_table: Dictionary = {}
static var _initialized: bool = false

# 初回アクセス時に自動初期化
static func create_hook(ability_id: String, medal_id: String) -> BattleHook:
	if not _initialized:
		_load_all_abilities()
	
	if not _ability_table.has(ability_id):
		push_error("Unknown ability: " + ability_id)
		return null
	
	var AbilityScript = _ability_table[ability_id]
	return AbilityScript.new(medal_id)

# フォルダスキャンしてテーブルに登録
static func _load_all_abilities():
	var dir = DirAccess.open("res://battle/hooks/abilities/")
	if not dir:
		push_error("Failed to open abilities folder")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".gd") and not file_name.begins_with("."):
			var script_path = "res://data/hooks/abilities/" + file_name
			var script = load(script_path)
			
			if script:
				# 一時インスタンスを作ってIDを取得
				var temp = script.new("")
				if temp.has("id") and temp.id != "":
					_ability_table[temp.id] = script
					print("Loaded ability: ", temp.id)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	_initialized = true
	print("Total abilities loaded: ", _ability_table.size())
