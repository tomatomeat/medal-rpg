extends Node

const SAVE_PATH := "user://save.json"

func load_all():
	var save_data := _read_json()

	MedalManager.load_medals(save_data.get("medal", {}))
	PartyManager.load_party(save_data.get("party", []))
	PlayerManager.load_player(save_data.get("player", {}))
	#ItemManager.load_items(save_data.get("item", {}))

func save_all() -> void:
	var save_data := {
		"player": PlayerManager.get_save_data(),
		"party": PartyManager.get_save_data(),
		"medal": MedalManager.get_save_data(),
		"item": ItemManager.get_save_data(),
	}
	var json := JSON.stringify(save_data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json)
	file.close()

func _read_json() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("Save JSON parse failed")
		return {}

	return json.data
