extends Node2D

@onready var start_button: Button = $Control/Panel/StartButton

func _ready():
	SaveManager.load_all()
	#MedalManager.create_medal("fraglow")
	#MedalManager.create_medal("sifaio")
	#MedalManager.create_medal("riroffar")
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	SceneManager.change_scene(SceneID.FIELD,{"Position":Vector2(0,0)})
