extends CanvasLayer

@onready var moldura_selecao_1: TextureRect = $HBoxContainer/MolduraSelecao1
@onready var moldura_selecao_2: TextureRect = $HBoxContainer/MolduraSelecao2
@onready var hbox_itens: Control = $HBoxContainer
@onready var fundo_geral: Control = $"Fundo Geral"
@onready var caixa_dialogo: Panel = get_node_or_null("Caixa_Dialogo")
@onready var texto_dialogo: Label = get_node_or_null("Caixa_Dialogo/Label")
@onready var timer_label: Label = get_node_or_null("TimerLabel")
@onready var timer_fundo: Control = get_node_or_null("TimerFundo")

# Caminhos originais mantidos
@onready var menu_vitoria: Control = get_node_or_null("MenuVitoria")
@onready var label_victory: Label = get_node_or_null("MenuVitoria/VBoxContainer/LabelVictory")
@onready var btn_reiniciar: TextureButton = get_node_or_null("MenuVitoria/VBoxContainer/HBoxContainer/BtnReiniciar")
@onready var btn_voltar: TextureButton = get_node_or_null("MenuVitoria/VBoxContainer/HBoxContainer/BtnVoltar")

## Selecione a cena de destino do botão 'Voltar' no Inspector
@export_file("*.tscn") var cena_destino: String = ""

var textura_moldura_1: Texture2D
var textura_moldura_2: Texture2D

func _ready() -> void:
	add_to_group("hud")
	hbox_itens.visible = false
	fundo_geral.visible = false
	textura_moldura_1 = moldura_selecao_1.texture
	textura_moldura_2 = moldura_selecao_2.texture
	
	if timer_label:
		timer_label.visible = false
	if timer_fundo:
		timer_fundo.visible = false

	# Garante via código que o painel de fundo não bloqueie o clique do mouse
	if menu_vitoria:
		menu_vitoria.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if fundo_geral:
		fundo_geral.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_definir_visibilidade_vitoria(false)

	# Configura permissão de clique direto nos botões
	if btn_reiniciar:
		btn_reiniciar.mouse_filter = Control.MOUSE_FILTER_STOP
		if not btn_reiniciar.pressed.is_connected(_on_btn_reiniciar_pressed):
			btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
			
	if btn_voltar:
		btn_voltar.mouse_filter = Control.MOUSE_FILTER_STOP
		if not btn_voltar.pressed.is_connected(_on_btn_voltar_pressed):
			btn_voltar.pressed.connect(_on_btn_voltar_pressed)

	call_deferred("_conectar_ao_jogador")
	call_deferred("_conectar_ao_game_manager")

func _conectar_ao_jogador() -> void:
	var player = get_node_or_null("player")
	if player and not player.item_changed.is_connected(_on_player_item_changed):
		player.item_changed.connect(_on_player_item_changed)
		_on_player_item_changed(player.equipped_item)

func _on_player_item_changed(new_item: int) -> void:
	moldura_selecao_1.texture = textura_moldura_1 if new_item == 1 else null
	moldura_selecao_2.texture = textura_moldura_2 if new_item == 2 else null
	moldura_selecao_1.self_modulate = Color.WHITE
	moldura_selecao_2.self_modulate = Color.WHITE

func _conectar_ao_game_manager() -> void:
	var manager = get_tree().get_first_node_in_group("game_manager")
	if manager == null:
		return
	if manager.has_signal("missao_iniciada") and not manager.missao_iniciada.is_connected(_on_missao_iniciada):
		manager.missao_iniciada.connect(_on_missao_iniciada)
	if manager.has_signal("tempo_atualizado") and not manager.tempo_atualizado.is_connected(_on_tempo_atualizado):
		manager.tempo_atualizado.connect(_on_tempo_atualizado)
	if manager.has_signal("missao_concluida") and not manager.missao_concluida.is_connected(_on_missao_concluida):
		manager.missao_concluida.connect(_on_missao_concluida)
	if manager.has_method("missao_em_andamento") and manager.missao_em_andamento():
		_on_missao_iniciada()

func _on_missao_iniciada() -> void:
	hbox_itens.visible = true
	fundo_geral.visible = true
	if timer_label:
		timer_label.visible = true
	if timer_fundo:
		timer_fundo.visible = true

func _on_tempo_atualizado(segundos: int) -> void:
	if timer_label:
		timer_label.text = "Tempo: %d" % segundos

func _on_missao_concluida() -> void:
	hbox_itens.visible = false
	fundo_geral.visible = false
	if timer_label:
		timer_label.visible = false
	if timer_fundo:
		timer_fundo.visible = false
	
	_definir_visibilidade_vitoria(true)

func _definir_visibilidade_vitoria(visivel: bool) -> void:
	if menu_vitoria:
		menu_vitoria.visible = visivel
	if btn_reiniciar:
		btn_reiniciar.visible = visivel
	if btn_voltar:
		btn_voltar.visible = visivel

func _on_btn_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()

func _on_btn_voltar_pressed() -> void:
	if cena_destino != "":
		get_tree().change_scene_to_file(cena_destino)
	else:
		push_warning("Configure a 'cena_destino' no Inspector da HUD!")

func mostrar_dialogo(texto: String) -> void:
	if caixa_dialogo and texto_dialogo:
		caixa_dialogo.visible = true
		texto_dialogo.text = texto

func esconder_dialogo() -> void:
	if caixa_dialogo:
		caixa_dialogo.visible = false
