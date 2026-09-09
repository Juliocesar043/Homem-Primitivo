extends Control

# Caminho exato da cena da caverna
var primeiro_mapa: String = "res://scene/caverna.tscn"
var como_jogar_scene: String = "res://scene/como_jogar.tscn"

func _on_iniciar_jogo_pressed() -> void:
	get_tree().change_scene_to_file(primeiro_mapa)

func _on_como_jogar_pressed() -> void:
	var como_jogar_instance = load(como_jogar_scene).instantiate()
	add_child(como_jogar_instance)
	como_jogar_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	como_jogar_instance.position = Vector2.ZERO
	como_jogar_instance.size = get_viewport_rect().size

func _on_sair_pressed() -> void:
	get_tree().quit()
