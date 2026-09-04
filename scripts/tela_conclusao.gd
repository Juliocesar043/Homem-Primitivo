extends CanvasLayer

@onready var btn_rejogar = $Panel/VBox/HBox/BtnRejogar
@onready var btn_voltar = $Panel/VBox/HBox/BtnVoltar

func _ready() -> void:
	btn_rejogar.pressed.connect(_on_rejogar)
	btn_voltar.pressed.connect(_on_voltar)

func _on_rejogar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_voltar() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/caverna.tscn")
