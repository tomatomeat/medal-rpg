extends Node2D

@onready var start_button: Button = $Control/Panel/StartButton

const FIELD_SCENE := preload("res://scenes/field.tscn")

func _ready():
	SaveManager.load_all()
	#MedalManager.create_medal("fraglow")
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	SceneManager.change_scene(SceneID.FIELD,{"Position":Vector2(0,0)})
