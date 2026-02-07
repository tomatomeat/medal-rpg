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

func _ready():
	BattleDirector.request_place_medals.connect(_on_place_medals)

func _on_place_medals(placements):
	for medal:MedalState in placements:
		
