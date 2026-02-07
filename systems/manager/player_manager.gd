extends Node

var data: PlayerData
var pending_apply := false

func new_game():
	data = PlayerData.new()
	data.current_area_id = "test"
	data.last_exit_id = "default"
	PlayerState.current_area_id = data.current_area_id
	PlayerState.last_exit_id = data.last_exit_id
	pending_apply = true

func load_player(save_data: Dictionary):
	data = PlayerData.new()
	data.current_area_id = save_data.get("current_area_id", "test")
	data.last_exit_id = save_data.get("last_exit_id", "default")
	PlayerState.current_area_id = data.current_area_id
	PlayerState.last_exit_id = data.last_exit_id
	pending_apply = true

# FieldController から呼ばれる
func apply_to_field(field):
	if not data:
		return

	field.load_area(data.current_area_id,data.last_exit_id)
	pending_apply = false

func get_save_data() -> Dictionary:
	return {
		"current_area_id": data.current_area_id,
		"last_exit_id": data.last_exit_id,
	}
