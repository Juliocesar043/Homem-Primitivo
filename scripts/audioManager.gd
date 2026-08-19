extends Node

# Um dicionário guardando os nomes dos sons e seus respectivos arquivos
var sons = {
	"pulo": preload("res://sounds/jump.wav"),
	"interagir": preload("res://sounds/interagir.wav"),
	"andarGrama": preload("res://sounds/Grama.wav")
}

func tocar_som(nome_do_som: String, variar_pitch: bool = false):
	# Verifica se o som existe no dicionário
	if not sons.has(nome_do_som):
		print("Erro: O som '", nome_do_som, "' não foi encontrado no AudioManager.")
		return
		
	# Cria um novo AudioStreamPlayer via código
	var player = AudioStreamPlayer.new()
	player.stream = sons[nome_do_som]
	
	if variar_pitch:
		# Sorteia um valor entre 0.85 (mais grave/lento) e 1.15 (mais agudo/rápido)
		# O valor padrão normal é 1.0
		player.pitch_scale = randf_range(0.85, 1.15)
	
	# Adiciona o player na árvore do jogo para ele poder tocar
	add_child(player)
	player.play()
	
	# Assim que o som terminar de tocar, o nó se deleta automaticamente da memória
	player.finished.connect(player.queue_free)
