extends Node

@export var command_ui: CommandUI
@export var director: BattleDirector

func _ready():
	director.command_ui = command_ui
	director.on_battle_scene_ready()
