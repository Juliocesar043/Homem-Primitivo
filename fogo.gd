extends Area2D

# Quando o jogador pisa no fogo avulso
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		GameManager.perder_vida()

# Quando a folha atinge o fogo avulso
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ataque"):
		queue_free() # Destrói (apaga) este nó da cena instantaneamente
