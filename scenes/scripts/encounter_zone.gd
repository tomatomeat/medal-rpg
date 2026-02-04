extends Area2D
class_name EncounterZone

@export var data: EncounterZoneData
@export var shape: Shape2D
@export var enabled := true

@onready var collision := $CollisionShape2D

func _ready():
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			EncounterManager.on_zone_enter(self)

func _on_body_entered(body):
	print("in")
	if not enabled:
		return
	if body.name == "Player":
		EncounterManager.on_zone_enter(self)

func _on_body_exited(body):
	print("out")
	if body.name == "Player":
		EncounterManager.on_zone_exit(self)
