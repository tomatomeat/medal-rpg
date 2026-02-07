extends Node
class_name FieldController

@onready var area_root := get_parent().get_node("AreaRoot")
@onready var player := get_parent().get_node("Player")

var current_area: Node
var current_area_id: String

func _ready():
	add_to_group("Field")
	
	if PlayerManager.pending_apply:
		PlayerManager.apply_to_field(self)

func load_area(area_id := "", exit_id := ""):
	current_area_id = area_id
	if current_area:
		current_area.queue_free()
		
	var area_scene = AreaDataBase.get_scene(area_id)
	current_area = area_scene.instantiate()
	area_root.add_child(current_area)
	
	await get_tree().process_frame
	
	var spawn_name := exit_id if exit_id != "" else "default"

	if current_area.has_node("SpawnPoints/" + spawn_name):
		player.global_position = current_area.get_node(
			"SpawnPoints/" + spawn_name
		).global_position
	else:
		player.global_position = current_area.get_node(
			"SpawnPoints/default"
		).global_position
	print("ho")
	PlayerState.current_area_id = current_area_id
	EncounterManager.set_area(current_area_id,true)
