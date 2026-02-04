extends Control

signal party_edit_pressed

@onready var party_edit_button := $PartyEdit

func _on_party_button_pressed():
	emit_signal("party_edit_pressed")
