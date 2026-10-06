extends Node

var sonsCarregados: Dictionary = {
	"pulo": preload("res://sounds/jump.wav"),
	"interagir": preload("res://sounds/interagir.wav"),
	"andarGrama": preload("res://sounds/Grama.wav"),
	"andarPedra": preload("res://sounds/andandoPedra.wav"),
	"atacar": preload("res://sounds/ataque.wav"),
	"dano": preload("res://sounds/hit.wav")
}

# --- BGM ---
var _bgm_player: AudioStreamPlayer = null
var _bgm_atual: String = ""

var _bgm_streams: Dictionary = {
	"tema": preload("res://sounds/musicaTema.wav"),
	"caverna": preload("res://sounds/musicaCaverna.wav")
}

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	_bgm_player.volume_db = -10.0
	add_child(_bgm_player)
	
	# Verificar imediatamente a cena inicial
	call_deferred("_verificar_cena_atual")

var _ultima_cena_nome: String = ""

func _process(_delta: float) -> void:
	_verificar_cena_atual()

func _verificar_cena_atual() -> void:
	var cena_atual = get_tree().current_scene
	if cena_atual == null:
		return
	var nome_cena: String = str(cena_atual.name)
	if nome_cena == _ultima_cena_nome:
		return
		
	_ultima_cena_nome = nome_cena
	
	# Seleciona a música baseada na cena
	if nome_cena == "Caverna" or nome_cena == "caverna":
		tocar_bgm("caverna")
	else:
		tocar_bgm("tema")

func tocar_bgm(tipo: String) -> void:
	if tipo == _bgm_atual and _bgm_player.playing:
		return  # Já está tocando a mesma música
	if not _bgm_streams.has(tipo):
		push_error("BGM '%s' não encontrada no AudioManager." % tipo)
		return
	_bgm_atual = tipo
	var stream: AudioStream = _bgm_streams[tipo]
	_bgm_player.stream = stream
	_bgm_player.play()
	print(">>> TOCANDO BGM: ", tipo)

func parar_bgm() -> void:
	_bgm_player.stop()
	_bgm_atual = ""

func tocarSom(nomeDoSom: String, variarPitch: bool = false) -> void:
	if not sonsCarregados.has(nomeDoSom):
		push_error("O som '%s' não foi encontrado no AudioManager." % nomeDoSom)
		return
		
	var reprodutorAudio = AudioStreamPlayer.new()
	reprodutorAudio.stream = sonsCarregados[nomeDoSom]
	
	# Normaliza o volume para não ficar muito alto
	if nomeDoSom == "atacar":
		reprodutorAudio.volume_db = -30.0 # O som de ataque é naturalmente muito mais estourado
	elif nomeDoSom.begins_with("andar"):
		reprodutorAudio.volume_db = -35.0 # Sons de passos precisam ser sutis
	else:
		reprodutorAudio.volume_db = -15.0
	
	if variarPitch:
		reprodutorAudio.pitch_scale = randf_range(0.85, 1.15)
	
	add_child(reprodutorAudio)
	reprodutorAudio.play()
	
	reprodutorAudio.finished.connect(reprodutorAudio.queue_free)
