extends Node2D

## Mundo da Vila.
##
## Regras de interação:
##  - NPCs revelam o ICONE DA DOENÇA (somente o ícone, sem texto) acima do jogador.
##  - Animais revelam o ICONE DO REMÉDIO (somente o ícone, sem texto) acima do jogador.
##  - A Tabela de Tratamentos é acessível EXCLUSIVAMENTE pela placa (estrutura)
##    no meio da vila, e é onde os pares sintoma x cura são associados.
##
## Cada item revelado também é liberado na Tabela, de forma que o jogador
## precisa conhecer a doença (no NPC) e o remédio (no animal) antes de
## conseguir associá-los.

## NPCs da vila -> ícone da doença que aquele personagem apresenta.
const DOENCAS_POR_NPC := {
	"NPCs - Enjoados": "IconEnjoo",
	"Npc - BracoMachucado": "IconMao",
	"NPC - Febre": "IconFebre",
	"NPC - velho": "IconVelho",
}

## Animais da vila -> ícone do remédio que aquele animal fornece.
const REMEDIOS_POR_ANIMAL := {
	"Javali": "Gengibre",
	"Lince": "Milfolhas",
	"Texugo": "PlantaVeneno",
	"Castor": "Casca",
}

@onready var jogador: CharacterBody2D = $player

const NASCIMENTO_VILA := Vector2(97.0, -32.0)
const DISTANCIA_ENTRADA_CASA := 180.0

var minijogo: Control = null
var areaInteracao: Area2D = null
var areaPorta: Area2D = null
var areaVoltar: Area2D = null
var estaNaCasa := false

## Tween do ícone exibido acima do jogador (usado para cancelá-lo com segurança).
var _tweenIcone: Tween = null


func _ready() -> void:
	minijogo = get_node_or_null("NPC-Minigame/CanvasLayer/JanelaMinigame")
	if jogador:
		var camera = jogador.get_node("Camera2D")


		camera.make_current()
		camera.limit_left = 10
		camera.limit_right = 100000
		camera.limit_top = -3000
		camera.limit_bottom = 200


	for nome_area in DOENCAS_POR_NPC.keys() + REMEDIOS_POR_ANIMAL.keys():
		var area: Area2D = get_node_or_null(nome_area)
		if area:
			area.body_entered.connect(_aoJogadorEntrarNaArea.bind(area))
			area.body_exited.connect(_aoJogadorSairDaArea.bind(area))

	areaPorta = get_node_or_null("Porta")
	areaVoltar = get_node_or_null("Voltar")
	if areaPorta:
		areaPorta.body_entered.connect(_aoJogadorEntrarNaArea.bind(areaPorta))
		areaPorta.body_exited.connect(_aoJogadorSairDaArea.bind(areaPorta))
	if areaVoltar:
		areaVoltar.body_entered.connect(_aoJogadorEntrarNaArea.bind(areaVoltar))
		areaVoltar.body_exited.connect(_aoJogadorSairDaArea.bind(areaVoltar))

func _process(_delta: float) -> void:
	if jogador == null or not is_instance_valid(jogador):
		return

	if Input.is_action_just_pressed("interagir"):
		# A Tabela de Tratamentos pertence exclusivamente à placa no meio da vila.
		# Enquanto ela estiver aberta, nenhuma outra interação deve ser disparada.
		if minijogo != null and minijogo.visible:
			return

		if areaInteracao != null:
			var nome_area: String = areaInteracao.name

			if nome_area == "Porta":
				teletransportarParaCasa()
				return

			if nome_area == "Voltar":
				teletransportarParaVila()
				return

			if DOENCAS_POR_NPC.has(nome_area):
				_revelarItem(DOENCAS_POR_NPC[nome_area])
				return

			if REMEDIOS_POR_ANIMAL.has(nome_area):
				_revelarItem(REMEDIOS_POR_ANIMAL[nome_area])
				return

	if jogador.global_position.y > 200:
		GameManager.perderVida()
		await get_tree().create_timer(1.0).timeout
		jogador.global_position = NASCIMENTO_VILA

func _aoJogadorEntrarNaArea(body: Node, area: Area2D) -> void:
	if body == jogador:
		areaInteracao = area
		if area == areaVoltar and estaNaCasa:
			teletransportarParaVila()

func _aoJogadorSairDaArea(body: Node, area: Area2D) -> void:
	if body == jogador and areaInteracao == area:
		areaInteracao = null

func teletransportarParaCasa() -> void:
	if jogador == null or areaVoltar == null:
		return
	areaInteracao = null
	estaNaCasa = true
	var posicaoInterior := areaVoltar.global_position + Vector2(DISTANCIA_ENTRADA_CASA, 0.0)
	jogador.definirPosicaoNascimento(posicaoInterior)

func teletransportarParaVila() -> void:
	if jogador == null or areaPorta == null:
		return
	areaInteracao = null
	estaNaCasa = false
	jogador.definirPosicaoNascimento(areaPorta.global_position)

## Revela o item acima do jogador e o libera para uso na Tabela de Tratamentos.
## O ícone pode ser consultado quantas vezes o jogador quiser.
func _revelarItem(idItem: String) -> void:
	if minijogo == null or not is_instance_valid(minijogo):
		return

	if minijogo.has_method("desbloquearItem"):
		minijogo.desbloquearItem(idItem)

	mostrarIconeAcimaDoJogador(idItem)

## Exibe APENAS o ícone do item acima do jogador (sem texto), para que ele
## identifique a doença do NPC ou o remédio do animal.
func mostrarIconeAcimaDoJogador(idItem: String) -> void:
	if jogador == null or not is_instance_valid(jogador):
		return
	if minijogo == null or not is_instance_valid(minijogo):
		return
	if not minijogo.has_method("obterBotao"):
		return

	# Remove o ícone anterior (se o jogador trocou de alvo rapidamente).
	if _tweenIcone != null and _tweenIcone.is_valid():
		_tweenIcone.kill()
		_tweenIcone = null
	if jogador.has_node("IconeSobreJogador"):
		jogador.get_node("IconeSobreJogador").queue_free()

	var botao: Button = minijogo.obterBotao(idItem)
	if botao == null or not is_instance_valid(botao):
		return
	if botao.icon == null:
		return

	var container = Node2D.new()
	container.name = "IconeSobreJogador"
	container.position = Vector2(0, -150)
	container.z_index = 100

	var icone = TextureRect.new()
	icone.texture = botao.icon
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.custom_minimum_size = Vector2(64, 64)
	icone.size = Vector2(64, 64)
	icone.position = Vector2(-32, -32)

	container.add_child(icone)
	jogador.add_child(container)

	# Suaviza o sumiço do ícone após um instante.
	_tweenIcone = get_tree().create_tween()
	_tweenIcone.tween_interval(1.2)
	_tweenIcone.tween_property(icone, "modulate:a", 0.0, 0.4)
	_tweenIcone.tween_callback(_removerIcone.bind(container))

func _removerIcone(container: Node) -> void:
	if is_instance_valid(container):
		container.queue_free()
