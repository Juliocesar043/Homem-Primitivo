extends Control

signal concluido

const PARES_CORRETOS = {
	"IconEnjoo": "Gengibre",
	"IconFebre": "Casca",
	"IconMao": "Milfolhas",
	"IconVelho": "PlantaVeneno"
}

const INFORMACOES_ITENS = {
	"IconEnjoo": {"label": "Enjoo", "tipo": "doenca", "descricao": "Sintoma de enjoo"},
	"IconMao": {"label": "Braço machucado", "tipo": "doenca", "descricao": "Lesão no braço"},
	"IconFebre": {"label": "Febre", "tipo": "doenca", "descricao": "Sintoma de febre"},
	"IconVelho": {"label": "Idoso", "tipo": "doenca", "descricao": "Problema do idoso"},
	"Gengibre": {"label": "Gengibre", "tipo": "cura", "descricao": "Alivia o enjoo"},
	"Milfolhas": {"label": "Milfolhas", "tipo": "cura", "descricao": "Ajuda na febre"},
	"PlantaVeneno": {"label": "Planta venenosa", "tipo": "cura", "descricao": "Cuida do braço machucado"},
	"Casca": {"label": "Casca", "tipo": "cura", "descricao": "Tratamento do idoso"},
}

var sintomaSelecionado: Button = null
var curaSelecionada: Button = null
var totalAcertos := 0
var itensDesbloqueados: Dictionary = {}
var botoesPorId: Dictionary = {}

func _ready() -> void:
	hide()
	_montar_botoes()
	_reiniciarMinijogo()

func alternarJanela() -> void:
	if visible:
		ocultarJanela()
	else:
		mostrarJanela()

func mostrarJanela() -> void:
	show()
	_reiniciarMinijogo()
	_limparSelecao()

func ocultarJanela() -> void:
	hide()
	_limparSelecao()

func _montar_botoes() -> void:
	for botao in _obter_botoes_sintomas():
		botoesPorId[botao.name] = botao
		botao.pressed.connect(_aoSelecionarSintoma.bind(botao))

	for botao in _obter_botoes_remedios():
		botoesPorId[botao.name] = botao
		botao.pressed.connect(_aoSelecionarCura.bind(botao))

func _obter_botoes_sintomas() -> Array[Button]:
	var botoes: Array[Button] = []
	var coluna = $TextureRect/HBoxContainer/ColunaAldeoes
	for nodo in coluna.get_children():
		if nodo is Button:
			botoes.append(nodo)
	return botoes

func _obter_botoes_remedios() -> Array[Button]:
	var botoes: Array[Button] = []
	var coluna = $TextureRect/HBoxContainer/ColunaRemedios
	for nodo in coluna.get_children():
		if nodo is Button:
			botoes.append(nodo)
	return botoes

func obterBotao(idItem: String) -> Button:
	if botoesPorId.has(idItem):
		return botoesPorId[idItem]
	return null

func desbloquearItem(idItem: String) -> bool:
	if not botoesPorId.has(idItem):
		return false

	var botao: Button = botoesPorId[idItem]
	if is_instance_valid(botao) and not itensDesbloqueados.has(idItem):
		itensDesbloqueados[idItem] = true
		botao.disabled = false
		botao.modulate = Color.WHITE
		return true
	return false

func _aoSelecionarSintoma(botao: Button) -> void:
	if not _podeUsar(botao):
		return
	if sintomaSelecionado and is_instance_valid(sintomaSelecionado):
		sintomaSelecionado.modulate = Color.WHITE
	sintomaSelecionado = botao
	sintomaSelecionado.modulate = Color.YELLOW
	_verificarPar()

func _aoSelecionarCura(botao: Button) -> void:
	if not _podeUsar(botao):
		return
	if curaSelecionada and is_instance_valid(curaSelecionada):
		curaSelecionada.modulate = Color.WHITE
	curaSelecionada = botao
	curaSelecionada.modulate = Color.YELLOW
	_verificarPar()

func _podeUsar(botao: Button) -> bool:
	return is_instance_valid(botao) and not botao.disabled and itensDesbloqueados.has(botao.name)

func _verificarPar() -> void:
	if sintomaSelecionado == null or curaSelecionada == null:
		return

	var nomeSintoma := sintomaSelecionado.name
	var nomeCura := curaSelecionada.name

	if PARES_CORRETOS.get(nomeSintoma) == nomeCura:
		_aplicarResposta(sintomaSelecionado, curaSelecionada, Color.GREEN, true)
		totalAcertos += 1
		_limparSelecao()
		if totalAcertos >= PARES_CORRETOS.size():
			if GameManager.has_method("completar_fase"):
				GameManager.completar_fase("vila")
			var tela = load("res://scene/tela_conclusao.tscn").instantiate()
			get_tree().current_scene.add_child(tela)
			concluido.emit()
			ocultarJanela()
		return

	_aplicarResposta(sintomaSelecionado, curaSelecionada, Color.RED, false)
	await get_tree().create_timer(0.3).timeout
	_limparSelecao()

func _aplicarResposta(sintoma: Button, cura: Button, cor: Color, correto: bool) -> void:
	sintoma.modulate = cor
	cura.modulate = cor
	if correto:
		sintoma.disabled = true
		cura.disabled = true
	else:
		sintoma.disabled = false
		cura.disabled = false

func _reiniciarMinijogo() -> void:
	totalAcertos = 0
	for botao in botoesPorId.values():
		if is_instance_valid(botao):
			if itensDesbloqueados.has(botao.name):
				botao.disabled = false
				botao.modulate = Color.WHITE
			else:
				botao.disabled = true
				botao.modulate = Color(0.35, 0.35, 0.35)
	_limparSelecao()

func _limparSelecao() -> void:
	sintomaSelecionado = null
	curaSelecionada = null

func obterItensDesbloqueados() -> Array[String]:
	var itens: Array[String] = []
	for idItem in itensDesbloqueados.keys():
		itens.append(str(idItem))
	return itens
