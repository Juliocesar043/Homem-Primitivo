extends Area2D

func _on_zona_dano_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		print("O jogador tomou dano na zona genérica!")
		GameManager.perder_vida()
