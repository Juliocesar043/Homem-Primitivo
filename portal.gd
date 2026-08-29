extends Area2D

@export_file("*.tscn") var proxima_cena: String 

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
		
	if proxima_cena != "":
		get_tree().call_deferred("change_scene_to_file", proxima_cena)
	else:
		push_error("ERRO: Caminho da cena não definido no Inspetor do Portal!")
