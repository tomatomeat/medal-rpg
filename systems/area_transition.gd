extends Area2D

@export var next_area_id: String
@export var exit_id: String

func _on_body_entered(body):
	if body.name == "Player":
		var field := get_tree().get_first_node_in_group("Field")
		field.load_area(next_area_id, exit_id)
