extends Node2D

const DESBLOQUEIOS_POR_AREA = {
	"NPCs - Enjoados": "IconEnjoo",
	"Npc - BracoMachucado": "IconMao",
	"NPC - Febre": "IconFebre",
	"NPC - velho": "IconVelho",
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

func _ready() -> void:
	jogador = get_node_or_null("player")
	minijogo = get_node_or_null("NPC-Minigame/CanvasLayer/JanelaMinigame")
	if jogador:
		var camera = jogador.get_node("Camera2D")

		
		camera.make_current()
		camera.limit_left = 10
		camera.limit_right = 100000
		camera.limit_top = -3000
		camera.limit_bottom = 200
		

	for nome_area in DESBLOQUEIOS_POR_AREA.keys():
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
		if minijogo != null and minijogo.visible:
			minijogo.ocultarJanela()
			return

		if areaInteracao == null:
			return

		var nome_area: String = areaInteracao.name
		if nome_area == "Porta":
			teletransportarParaCasa()
			return

		if nome_area == "Voltar":
			teletransportarParaVila()
			return

		if DESBLOQUEIOS_POR_AREA.has(nome_area):
			var idItem: String = DESBLOQUEIOS_POR_AREA[nome_area]
			if minijogo != null and minijogo.has_method("desbloquearItem"):
				if minijogo.desbloquearItem(idItem):
					mostrarFeedbackDesbloqueio(idItem)
					minijogo.mostrarJanela()
				return

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

func mostrarFeedbackDesbloqueio(idItem: String) -> void:
	if jogador == null or not is_instance_valid(jogador):
		return
	if minijogo == null or not is_instance_valid(minijogo):
		return
	if not minijogo.has_method("obterBotao"):
		return
	if jogador.has_node("FeedbackDesbloqueio"):
		jogador.get_node("FeedbackDesbloqueio").queue_free()

	var button: Button = minijogo.obterBotao(idItem)
	if button == null or not is_instance_valid(button):
		return
	if button.icon == null:
		return

	var container = Node2D.new()
	container.name = "FeedbackDesbloqueio"
	container.position = Vector2(0, -105)
	container.z_index = 100

	var icon = TextureRect.new()
	icon.texture = button.icon
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(40, 40)
	icon.position = Vector2(-20, -12)

	var title = Label.new()
	title.text = idItem
	title.position = Vector2(30, -8)
	title.modulate = Color.WHITE
	title.add_theme_font_size_override("font_size", 16)

	container.add_child(icon)
	container.add_child(title)
	jogador.add_child(container)
	await get_tree().create_timer(1.4).timeout
	if is_instance_valid(container):
		container.queue_free()
