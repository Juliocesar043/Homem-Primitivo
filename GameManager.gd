extends Node

var vidas: int = 3

func perder_vida() -> void:
	var player = get_tree().get_first_node_in_group("jogador")
	
	if not player:
		return
		
	# Verifica com segurança se o jogador pode sofrer dano (não está invulnerável)
	if player.has_method("pode_receber_dano"):
		if not player.pode_receber_dano():
			return
	
	_descontar_vida()
	_aplicar_dano_no_jogador(player)
	_verificar_game_over()

func _descontar_vida() -> void:
	vidas -= 1
	print("Vidas restantes: ", vidas)

func _aplicar_dano_no_jogador(player: Node) -> void:
	if player.has_method("receber_dano"):
		player.receber_dano()
		
	if player.has_method("atualizar_vidas"):
		player.atualizar_vidas(vidas)

func _verificar_game_over() -> void:
	if vidas <= 0:
		print("Game Over! Recomeçando...")
		vidas = 3 # Reseta as vidas para 3
		get_tree().reload_current_scene()
