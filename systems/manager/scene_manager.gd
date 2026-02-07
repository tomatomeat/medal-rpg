extends Node

var current_scene: Node
var current_scene_id: int
var previous_scene_id: int
var context: Dictionary = {}

const SCENE_TABLE := {
	SceneID.FIELD: "res://scenes/field.tscn",
	SceneID.BATTLE: "res://scenes/battle.tscn",
	SceneID.PARTYEDIT: "res://scenes/party_edit.tscn",
	SceneID.MAIN: "res://scenes/main.tscn",
}

func _ready() -> void:
	current_scene = get_tree().current_scene
	current_scene_id = SceneID.MAIN

# =========================
# メインAPI
# =========================
func change_scene(scene_id: int, ctx: Dictionary = {}) -> void:
	context = ctx.duplicate(true)
	previous_scene_id = current_scene_id
	
	current_scene_id = scene_id

	var path :String = SCENE_TABLE.get(scene_id, "")
	if path == "":
		push_error("Scene not found for id: " + str(scene_id))
		return

	var packed: PackedScene = load(path)
	_change_scene(packed)

# =========================
# 内部処理
# =========================
func _change_scene(scene: PackedScene) -> void:
	if current_scene:
		current_scene.queue_free()

	var new_scene := scene.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene
