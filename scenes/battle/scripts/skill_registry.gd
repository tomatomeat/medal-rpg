extends Object
class_name SkillRegistry

static var _skill_table: Dictionary = {}
static var _initialized: bool = false

# 初回アクセス時に自動初期化
static func create_hook(skill_id: String, medal_id: String) -> BattleHook:
	if not _initialized:
		_load_all_skills()
	
	if not _skill_table.has(skill_id):
		push_error("Unknown skill: " + skill_id)
		return null
	
	var SkillScript = _skill_table[skill_id]
	return SkillScript.new(medal_id)

# フォルダスキャンしてテーブルに登録
static func _load_all_skills():
	var dir = DirAccess.open("res://data/hooks/skills/")
	if not dir:
		push_error("Failed to open skills folder")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".gd") and not file_name.begins_with("."):
			var script_path = "res://data/hooks/skills/" + file_name
			var script = load(script_path)
			
			if script:
				# 一時インスタンスを作ってIDを取得
				var temp = script.new("")
				if temp.has("id") and temp.id != "":
					_skill_table[temp.id] = script
					print("Loaded skill: ", temp.id)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	_initialized = true
	print("Total skills loaded: ", _skill_table.size())
