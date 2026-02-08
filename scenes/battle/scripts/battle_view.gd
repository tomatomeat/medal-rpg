extends Node2D

@onready var p1_markers = {
	0: $"MedalLayer/Markers/P1/1",
	1: $"MedalLayer/Markers/P1/2",
	2: $"MedalLayer/Markers/P1/3",
}

@onready var p2_markers = {
	0: $"MedalLayer/Markers/P2/1",
	1: $"MedalLayer/Markers/P2/2",
	2: $"MedalLayer/Markers/P2/3",
}

var context

func _ready():
	BattleDirector.request_battle_context.connect(get_context)

func get_context(ctx: BattleState):
	context = ctx
	var placements = context.medal_map.values().duplicate()
	_on_place_medals(placements)

func _on_place_medals(placements):
	for medal:MedalState in placements:
		print(medal)
