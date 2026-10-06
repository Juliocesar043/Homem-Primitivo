extends Node

var vidas: int = 3

var fases_concluidas: Dictionary = {
	"floresta": false,
	"lago": false,
	"vila": false
}

var fases_pintadas: Dictionary = {
	"floresta": false,
	"lago": false,
	"vila": false
}

# --- Speedrun Timer ---
var tempo_inicio_run: int = 0   # Momento em que a run iniciou (ticks_msec)
var ultima_run_ms: int = 0      # Duração da última run completa em milissegundos

func iniciar_run() -> void:
	tempo_inicio_run = Time.get_ticks_msec()

func finalizar_run() -> void:
	if tempo_inicio_run > 0:
		ultima_run_ms = Time.get_ticks_msec() - tempo_inicio_run
		tempo_inicio_run = 0

func formatar_tempo(ms: int) -> String:
	var total_seg := ms / 1000
	var minutos := total_seg / 60
	var segundos := total_seg % 60
	return "%02d:%02d" % [minutos, segundos]

func resetar_jogo() -> void:
	vidas = 3
	for fase in fases_concluidas.keys():
		fases_concluidas[fase] = false
	for fase in fases_pintadas.keys():
		fases_pintadas[fase] = false

func completar_fase(nome_fase: String) -> void:
	if fases_concluidas.has(nome_fase):
		fases_concluidas[nome_fase] = true
func perderVida() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return

	if player.has_method("possuiSistemaDeVida") and not player.possuiSistemaDeVida():
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
