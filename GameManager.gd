extends Node

var vidas = 3

func perder_vida():
	# 1. Encontra o jogador na cena
	var player = get_tree().get_first_node_in_group("jogador")
	
	# 2. Se o jogador existir e já estiver invulnerável, ignora o dano (sai da função)
	if player and player.invulneravel:
		return 
		
	# 3. Tira uma vida
	vidas -= 1
	print("Vidas restantes: ", vidas)
	
	# 4. Faz o jogador sofrer o empurrão
	if player and player.has_method("receber_dano"):
		player.receber_dano()
		
		if player.has_method("atualizar_vidas"):
			player.atualizar_vidas(vidas)
		
	# 5. GAME OVER: Se a vida zerar, reseta e recomeça a fase!
	if vidas <= 0:
		print("Game Over! Recomeçando...")
		vidas = 3 # Reseta as vidas para 3
		get_tree().reload_current_scene() # Recarrega a fase atual do zero
