extends Area2D

func _on_zona_dano_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("O neandertal se queimou na árvore!")
		# Se o seu player já tiver uma função de vida, chame-a aqui:
		# body.levar_dano(1)


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
