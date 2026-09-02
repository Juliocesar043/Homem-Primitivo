extends Node

## Game manager for the Fase_Lago ecological loop.
## Controls the mission timer, counts trash and nests, and reloads on timeout.

signal missao_iniciada
signal missao_concluida
signal missao_falhou
signal objetivo_atualizado(lixo_restante: int, ninhos_restante: int)
signal tempo_atualizado(segundos_restantes: int)

@export var tempo_missao: float = 90.0
@export var barreira_path: NodePath = NodePath()

@onready var timer: Timer = $Timer

var lixo_total: int = 0
var ninhos_total: int = 0
var lixo_restante: int = 0
var ninhos_restante: int = 0

var _iniciada: bool = false
var _concluida: bool = false
var _hud_timer: Timer

func _ready() -> void:
	add_to_group("game_manager")
	# A barreira inicia ativa e e liberada somente ao iniciar a missao.
	timer.wait_time = tempo_missao
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	_hud_timer = Timer.new()
	_hud_timer.wait_time = 0.5
	_hud_timer.timeout.connect(_emitir_tempo)
	add_child(_hud_timer)
	call_deferred("_contar_objetivos")

func _contar_objetivos() -> void:
	lixo_total = get_tree().get_nodes_in_group("lixo").size()
	ninhos_total = get_tree().get_nodes_in_group("ninho").size()
	lixo_restante = lixo_total
	ninhos_restante = ninhos_total
	objetivo_atualizado.emit(lixo_restante, ninhos_restante)

func iniciar_missao() -> void:
	if _iniciada:
		return
	_iniciada = true
	_liberar_barreira()
	timer.start()
	if _hud_timer:
		_hud_timer.start()
	missao_iniciada.emit()
	objetivo_atualizado.emit(lixo_restante, ninhos_restante)
	_emitir_tempo()

func _emitir_tempo() -> void:
	if not missao_em_andamento():
		return
	tempo_atualizado.emit(ceili(timer.time_left))

func missao_em_andamento() -> bool:
	return _iniciada and not _concluida

func notificar_lixo_removido() -> void:
	if not missao_em_andamento():
		return
	lixo_restante = maxi(lixo_restante - 1, 0)
	objetivo_atualizado.emit(lixo_restante, ninhos_restante)
	_verificar_conclusao()

func notificar_ninho_removido() -> void:
	if not missao_em_andamento():
		return
	ninhos_restante = maxi(ninhos_restante - 1, 0)
	objetivo_atualizado.emit(lixo_restante, ninhos_restante)
	_verificar_conclusao()

func _verificar_conclusao() -> void:
	if _concluida:
		return
	if lixo_restante <= 0 and ninhos_restante <= 0:
		_concluida = true
		timer.stop()
		if _hud_timer:
			_hud_timer.stop()
		tempo_atualizado.emit(0)
		_revelar_peixes()
		missao_concluida.emit()
		

func _on_timer_timeout() -> void:
	if _concluida:
		return
	if _hud_timer:
		_hud_timer.stop()
	missao_falhou.emit()
	get_tree().reload_current_scene()
func _revelar_peixes() -> void:
	# Chama o método 'ativar()' em cada peixe da cena
	get_tree().call_group("peixe", "ativar")
func _liberar_barreira() -> void:
	if barreira_path.is_empty():
		push_warning("barreira_path esta vazio; a barreira do lago nao foi liberada.")
		return
	var barreira := get_node_or_null(barreira_path)
	if barreira == null:
		push_warning("Barreira nao encontrada em %s" % str(barreira_path))
		return
	if barreira is StaticBody2D:
		barreira.collision_layer = 0
		barreira.collision_mask = 0
	var forma := barreira.get_node_or_null("CollisionShape2D")
	if forma:
		forma.set_deferred("disabled", true)
