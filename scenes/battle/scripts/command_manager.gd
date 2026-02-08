extends Node

@export var command_ui: CommandUI

func _ready():
	BattleDirector.bind_command_ui(command_ui)
	BattleDirector.on_battle_scene_ready()
