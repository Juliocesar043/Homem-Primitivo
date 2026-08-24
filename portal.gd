extends Area2D

# Mudamos de PackedScene para String (Caminho do arquivo)
@export_file("*.tscn") var proxima_cena: String 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		# Checa se o texto do caminho não está vazio
		if proxima_cena != "":
			# Muda de change_scene_to_packed para change_scene_to_file
			get_tree().call_deferred("change_scene_to_file", proxima_cena)
		else:
			print("ERRO: Caminho da cena vazio no Inspetor!")
