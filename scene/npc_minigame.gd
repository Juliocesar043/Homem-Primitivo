extends Control

var sintoma_atual: Button = null
var remedio_atual: Button = null

const PARES_CORRETOS = {
	"IconEnjoo": "Gengibre",
	"IconMao": "PlantaVeneno",
	"IconFebre": "Milfolhas",
	"IconVelho": "Casca"
}

var acertos_totais = 0

func _ready():
	conectar_botoes()

func conectar_botoes():
	for botao in $TextureRect/HBoxContainer/ColunaAldeoes.get_children():
		if botao is Button:
			botao.pressed.connect(func(): _selecionar_sintoma(botao))
			
	for botao in $TextureRect/HBoxContainer/ColunaRemedios.get_children():
		if botao is Button:
			botao.pressed.connect(func(): _selecionar_remedio(botao))

func _selecionar_sintoma(botao: Button):
	if sintoma_atual and is_instance_valid(sintoma_atual):
		sintoma_atual.modulate = Color(1, 1, 1)
		
	sintoma_atual = botao
	sintoma_atual.modulate = Color(1, 1, 0)
	verificar_par()

func _selecionar_remedio(botao: Button):
	if remedio_atual and is_instance_valid(remedio_atual):
		remedio_atual.modulate = Color(1, 1, 1)
		
	remedio_atual = botao
	remedio_atual.modulate = Color(1, 1, 0)
	verificar_par()

func verificar_par():
	if sintoma_atual != null and remedio_atual != null:
		var nome_sintoma = sintoma_atual.name
		var nome_remedio = remedio_atual.name
		
		if PARES_CORRETOS.get(nome_sintoma) == nome_remedio:
			sintoma_atual.modulate = Color(0, 1, 0)
			remedio_atual.modulate = Color(0, 1, 0)
			sintoma_atual.disabled = true
			remedio_atual.disabled = true
			acertos_totais += 1
			_limpar_selecao()
			
			if acertos_totais >= 4:
				print("MINIGAME CONCLUÍDO!")
		else:
			sintoma_atual.modulate = Color(1, 0, 0)
			remedio_atual.modulate = Color(1, 0, 0)
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(sintoma_atual) and not sintoma_atual.disabled:
				sintoma_atual.modulate = Color(1, 1, 1)
			if is_instance_valid(remedio_atual) and not remedio_atual.disabled:
				remedio_atual.modulate = Color(1, 1, 1)
			_limpar_selecao()

func _limpar_selecao():
	sintoma_atual = null
	remedio_atual = null
