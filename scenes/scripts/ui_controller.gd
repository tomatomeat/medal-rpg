extends Node

@onready var menu: Control = get_parent().get_node("CanvasLayer").get_node("FieldUI").get_node("Menu")

func _ready():
	InputManager.menu_pressed.connect(_on_menu_pressed)
	menu.party_edit_pressed.connect(_on_party_edit)

func _on_menu_pressed():
	if GameState.state == GameState.State.FIELD:
		open_menu()
	elif GameState.state == GameState.State.MENU:
		close_menu()

func open_menu():
	GameState.state = GameState.State.MENU
	menu.visible = true
	#get_tree().paused = true
	
func close_menu():
	GameState.state = GameState.State.FIELD
	menu.visible = false
	#get_tree().paused = false

func _on_party_edit():
	SceneManager.change_scene(SceneID.PARTYEDIT,{current_area=PlayerState.current_area_id})
