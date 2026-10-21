extends Node

## Gerenciador da missão da Floresta.
## Controla o timer da missão, conta os fogos, detecta out-of-bounds,
## e recarrega a cena em caso de timeout ou queda.

signal missao_iniciada
signal missao_concluida
signal missao_falhou
signal objetivo_atualizado(fogos_restantes: int)
signal tempo_atualizado(segundos_restantes: int)

@export var tempo_missao: float = 120.0
@export var limite_queda_y: float = 3000.0

var total_fogos: int = 0
var fogos_apagados: int = 0
var concluida: bool = false

var _iniciada: bool = false
var _timer: Timer
var _hud_timer: Timer

func _ready() -> void:
	add_to_group("game_manager")
	
	# Criar Timer principal da missão
	_timer = Timer.new()
	_timer.wait_time = tempo_missao
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	# Criar Timer de atualização do HUD (emite a cada 0.5s)
	_hud_timer = Timer.new()
	_hud_timer.wait_time = 0.5
	_hud_timer.timeout.connect(_emitir_tempo)
	add_child(_hud_timer)
	
	_criar_ui_timer()
	call_deferred("_contar_fogos")

var _timer_label: Label = null

func _criar_ui_timer() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 50
	
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.offset_right = -20
	panel.offset_top = 20
	
	_timer_label = Label.new()
	_timer_label.text = "Tempo: %d" % tempo_missao
	_timer_label.add_theme_font_size_override("font_size", 24)
	
	panel.add_child(_timer_label)
	canvas.add_child(panel)
	add_child(canvas)

func _contar_fogos() -> void:
	var scene_root = get_tree().current_scene
	var nodes = scene_root.find_children("*", "Node", true, false)
	for n in nodes:
		if n.get_script():
			var s_path = n.get_script().resource_path
			if s_path.ends_with("arvore_fogo.gd") or s_path.ends_with("arbusto_fogo.gd"):
				total_fogos += 1
				if n.has_signal("fogo_apagado"):
					n.fogo_apagado.connect(_on_fogo_apagado)
			elif s_path.ends_with("fogo.gd"):
				total_fogos += 1
				n.tree_exiting.connect(_on_fogo_apagado)
	print("ForestManager: found ", total_fogos, " fires.")
	
	# Iniciar a missão automaticamente ao carregar a fase
	_iniciar_missao()

func _iniciar_missao() -> void:
	if _iniciada:
		return
	_iniciada = true
	_timer.start()
	_hud_timer.start()
	missao_iniciada.emit()
	objetivo_atualizado.emit(total_fogos - fogos_apagados)
	_emitir_tempo()

func missao_em_andamento() -> bool:
	return _iniciada and not concluida

func _emitir_tempo() -> void:
	if not missao_em_andamento():
		return
	var tempo_restante = ceili(_timer.time_left)
	tempo_atualizado.emit(tempo_restante)
	if _timer_label:
		_timer_label.text = "Tempo: %d" % tempo_restante

func _process(_delta: float) -> void:
	_verificar_out_of_bounds()

func _verificar_out_of_bounds() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if player.global_position.y > limite_queda_y:
		print("ForestManager: Jogador caiu fora do mapa! Reiniciando fase...")
		get_tree().reload_current_scene()

func _on_fogo_apagado() -> void:
	fogos_apagados += 1
	objetivo_atualizado.emit(total_fogos - fogos_apagados)
	if fogos_apagados >= total_fogos and not concluida:
		concluida = true
		_timer.stop()
		_hud_timer.stop()
		tempo_atualizado.emit(0)
		if GameManager.has_method("completar_fase"):
			GameManager.completar_fase("floresta")
		missao_concluida.emit()
		var tela = load("res://scene/tela_conclusao.tscn").instantiate()
		get_tree().current_scene.add_child(tela)

func _on_timer_timeout() -> void:
	if concluida:
		return
	_hud_timer.stop()
	missao_falhou.emit()
	print("ForestManager: Tempo esgotado! Reiniciando fase...")
	get_tree().reload_current_scene()
