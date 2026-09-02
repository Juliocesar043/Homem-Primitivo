extends Node

var vidas: int = 3

func perderVida() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
		
	if player.has_method("podeReceberDano"):
		if not player.podeReceberDano():
			return
	
	_descontarVida()
	_aplicarDanoNoJogador(player)
	_verificarGameOver()

func _descontarVida() -> void:
	vidas -= 1
	print("Vidas restantes: ", vidas)

func _aplicarDanoNoJogador(player: Node) -> void:
	if player.has_method("receberDano"):
		player.receberDano()
		
	if player.has_method("atualizarVidas"):
		player.atualizarVidas(vidas)

func _verificarGameOver() -> void:
	if vidas <= 0:
		print("Game Over! Recomeçando...")
		vidas = 3 # Reseta as vidas para 3
		get_tree().reload_current_scene()
