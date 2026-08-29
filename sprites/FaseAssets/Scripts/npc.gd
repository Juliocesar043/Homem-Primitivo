extends Area2D

# Aqui você pode escrever as falas do NPC no Inspector!
@export var falas: Array[String] = [
	"Ei, você aí! O lago está imundo e os peixes estão morrendo de fome.",
	"Use o Saco de lixo (tecla 1) para tirar o lixo da água.",
	"Use a Ração (tecla 2) para alimentar os ninhos.",
	"Você não tem muito tempo antes que seja tarde demais. Limpe o lago agora!"
]

var jogador_perto: bool = false
var conversando: bool = false
var indice_fala: int = 0

var _jogador: Node2D = null
var _enter_pressionado_anteriormente: bool = false
var dica_dialogo: Label = null

const TEXTO_DICA: String = "Aperte Enter para dialogo"

func _ready() -> void:
	# Conecta os sinais de entrada e saída da área
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_criar_dica_dialogo()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_perto = true
		_jogador = body
		_mostrar_dica()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_perto = false
		_esconder_dica()
		_jogador = null
		encerrar_dialogo()

func avancar_dialogo() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud: return
	
	if not conversando:
		conversando = true
		indice_fala = 0
		
	if indice_fala < falas.size():
		# Mostra a fala atual e prepara a próxima
		hud.mostrar_dialogo(falas[indice_fala])
		indice_fala += 1
	else:
		# Acabaram as falas
		encerrar_dialogo()
		iniciar_missao()

func encerrar_dialogo() -> void:
	conversando = false
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.esconder_dialogo()

func iniciar_missao() -> void:
	var manager = get_tree().get_first_node_in_group("game_manager")
	if manager and manager.has_method("iniciar_missao"):
		manager.iniciar_missao()

func _criar_dica_dialogo() -> void:
	dica_dialogo = Label.new()
	dica_dialogo.name = "DicaDialogo"
	dica_dialogo.text = TEXTO_DICA
	dica_dialogo.visible = false
	dica_dialogo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dica_dialogo.z_index = 10
	dica_dialogo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dica_dialogo.custom_minimum_size = Vector2(320, 40)
	# Tipografia igual a da Caixa_Dialogo (fonte padrao), com contorno para leitura no mundo.
	dica_dialogo.add_theme_constant_override("outline_size", 4)
	dica_dialogo.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(dica_dialogo)

func _process(_delta: float) -> void:
	var enter_pressionado := Input.is_key_pressed(KEY_ENTER)
	var enter_novo := enter_pressionado and not _enter_pressionado_anteriormente
	var aceitar := Input.is_action_just_pressed("ui_accept") or enter_novo
	if jogador_perto and aceitar:
		avancar_dialogo()
	_enter_pressionado_anteriormente = enter_pressionado
	if dica_dialogo and dica_dialogo.visible and is_instance_valid(_jogador):
		dica_dialogo.global_position = _jogador.global_position + Vector2(-160, 90)

func _mostrar_dica() -> void:
	if dica_dialogo and is_instance_valid(_jogador):
		dica_dialogo.global_position = _jogador.global_position + Vector2(-160, 90)
		dica_dialogo.visible = true

func _esconder_dica() -> void:
	if dica_dialogo:
		dica_dialogo.visible = false
