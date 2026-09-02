extends CharacterBody2D

# ==============================================================================
# CONSTANTES
# ==============================================================================
const velocidadeMovimento: float = 300.0
const forcaPulo: float = -600.0
const forcaKnockback: float = 350.0
const limiteQuedaY: float = 1000.0
const velocidadeNado: float = 180.0

# ==============================================================================
# REFERÊNCIAS DE NÓS
# ==============================================================================
@onready var hudNomeFase: Label = $HUD/NomeFaseLabel
@onready var hudVidas: Label = $HUD/VidasLabel
@onready var animSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitboxAtaque: CollisionShape2D = $AtaqueFolha/CollisionShape2D
@onready var animFolha: AnimatedSprite2D = $AtaqueFolha/folha
@onready var camera: Camera2D = $Camera2D

# ==============================================================================
# VARIÁVEIS DE ESTADO GERAL
# ==============================================================================
@export var nomeFase: String = "A Floresta"

var estavaNoAr: bool = false
var estaPousando: bool = false
var estaAtacando: bool = false
var estaTomandoDano: bool = false
var estaInvulneravel: bool = false
var posicaoNascimento: Vector2 = Vector2.ZERO

# ==============================================================================
# VARIÁVEIS DE ESTADO (LAGO E NADO)
# ==============================================================================
var estaNadando: bool = false
var tempoNado: float = 0.0

enum Item { NENHUM, SACO_LIXO, RACAO_PEIXE }
var itemEquipado: Item = Item.NENHUM

signal itemAlterado(novoItem: Item)

# ==============================================================================
# FUNÇÕES PRINCIPAIS
# ==============================================================================
func _ready() -> void:
	add_to_group("player")
	_configurarInterface()
	
	if animSprite and not animSprite.animation_finished.is_connected(_aoTerminarAnimacaoSprite):
		animSprite.animation_finished.connect(_aoTerminarAnimacaoSprite)
	
	if camera:
		var nomeCena = get_tree().current_scene.name
		if nomeCena == "Fase_Lago" or nomeCena == "Node2D":
			camera.limit_bottom = 721
			camera.limit_top = -483
			camera.limit_right = 5202
			camera.limit_left = -4
		elif nomeCena == "VillageWorld":
			camera.limit_left = 10
			camera.limit_right = 100000
			camera.limit_top = -3000
			camera.limit_bottom = 200
		else:
			camera.limit_left = -10000000
			camera.limit_top = -10000000
			camera.limit_right = 10000000
			camera.limit_bottom = 10000000

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("_on_player_item_changed"):
		itemAlterado.connect(hud._on_player_item_changed)
		itemAlterado.emit(itemEquipado)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			itemEquipado = Item.SACO_LIXO
			itemAlterado.emit(itemEquipado)
		elif event.keycode == KEY_2:
			itemEquipado = Item.RACAO_PEIXE
			itemAlterado.emit(itemEquipado)

func _physics_process(delta: float) -> void:
	if estaNadando:
		_processarNado(delta)
	else:
		_processarTerra(delta)

	move_and_slide()
	_verificarLimitesDoMapa()

# ==============================================================================
# LÓGICA DE TERRA E MOVIMENTAÇÃO PADRÃO
# ==============================================================================
func _processarTerra(delta: float) -> void:
	modulate = Color.WHITE
	rotation = lerp_angle(rotation, 0.0, 0.2)
	tempoNado = 0.0
	
	if estaTomandoDano:
		return
	
	_aplicarGravidade(delta)
	_processarEntradasDeAcao()
	
	var direcao := Input.get_axis("ui_left", "ui_right")
	if direcao != 0:
		_virarPersonagem(direcao)
		velocity.x = direcao * velocidadeMovimento
	else:
		velocity.x = move_toward(velocity.x, 0, velocidadeMovimento)
		
	_atualizarAnimacoes()

func _aplicarGravidade(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _virarPersonagem(direcao: float) -> void:
	if direcao < 0:
		animSprite.flip_h = true
		if has_node("AtaqueFolha"):
			$AtaqueFolha.scale.x = -1
	elif direcao > 0:
		animSprite.flip_h = false
		if has_node("AtaqueFolha"):
			$AtaqueFolha.scale.x = 1

func _verificarLimitesDoMapa() -> void:
	if global_position.y > limiteQuedaY and posicaoNascimento != Vector2.ZERO:
		reiniciarNaPosicaoNascimento()

# ==============================================================================
# LÓGICA DE NADO (Fase do Lago)
# ==============================================================================
func _obterEntradaMovimentoNado() -> Vector2:
	var direcaoEntrada := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		direcaoEntrada.x = -1.0
	elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		direcaoEntrada.x = 1.0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		direcaoEntrada.y = -1.0
	elif Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		direcaoEntrada.y = 1.0
	return direcaoEntrada.normalized()

func _processarNado(delta: float) -> void:
	tempoNado += delta
	var direcaoEntrada := _obterEntradaMovimentoNado()
	var velocidadeAlvo = direcaoEntrada * velocidadeNado
	velocity = velocity.move_toward(velocidadeAlvo, 12.0)

	if velocity.length() > 30:
		animSprite.play("jump")
	else:
		animSprite.play("fall")

	if direcaoEntrada != Vector2.ZERO:
		var anguloAlvo = direcaoEntrada.y * 0.35
		if animSprite.flip_h:
			anguloAlvo *= -1.0
		rotation = lerp_angle(rotation, anguloAlvo, 0.1)
	else:
		rotation = lerp_angle(rotation, 0.0, 0.1)
		velocity.y = sin(tempoNado * 4.0) * 20.0 

	if direcaoEntrada.x < 0:
		animSprite.flip_h = true
	elif direcaoEntrada.x > 0:
		animSprite.flip_h = false

	modulate = Color(0.7, 0.9, 1.0, 0.85)

func _on_area_agua_body_entered(body: Node2D) -> void:
	if body == self:
		estaNadando = true

func _on_area_agua_body_exited(body: Node2D) -> void:
	if body == self:
		estaNadando = false

# ==============================================================================
# LÓGICA DE AÇÕES
# ==============================================================================
func _processarEntradasDeAcao() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_pular()
		
	if Input.is_action_just_pressed("atacar") and not estaAtacando:
		_atacar()
		
	if Input.is_action_just_pressed("interagir") and is_on_floor():
		_interagir()

func _pular() -> void:
	velocity.y = forcaPulo
	_tocarSomSeguro("pulo", true)

func _interagir() -> void:
	_tocarSomSeguro("interagir")

func _atacar() -> void:
	estaAtacando = true
	
	if hitboxAtaque:
		hitboxAtaque.disabled = false
	
	if animFolha:
		animFolha.visible = true
		animFolha.rotation_degrees = -30
		var interpolacao = get_tree().create_tween()
		interpolacao.tween_property(animFolha, "rotation_degrees", 100, 0.2)
	
	animSprite.play("atacar")
	_tocarSomSeguro("atacar")
	
	await get_tree().create_timer(0.3).timeout
	
	if hitboxAtaque:
		hitboxAtaque.disabled = true
		
	if animFolha:
		animFolha.visible = false
		animFolha.rotation_degrees = 0
		
	estaAtacando = false

# ==============================================================================
# SISTEMA DE DANO
# ==============================================================================
func podeReceberDano() -> bool:
	return not estaInvulneravel

func receberDano() -> void:
	if estaInvulneravel:
		return
		
	estaInvulneravel = true
	estaTomandoDano = true
	
	_aplicarKnockback()
	
	animSprite.modulate = Color(1, 0, 0)
	_tocarSomSeguro("dano")
	await get_tree().create_timer(0.3).timeout
	
	estaTomandoDano = false
	animSprite.modulate = Color(1, 1, 1, 0.5)
	
	await get_tree().create_timer(1.0).timeout
	
	animSprite.modulate = Color(1, 1, 1, 1)
	estaInvulneravel = false

func _aplicarKnockback() -> void:
	velocity.y = -forcaKnockback
	if animSprite.flip_h:
		velocity.x = forcaKnockback
	else:
		velocity.x = -forcaKnockback

# ==============================================================================
# LÓGICA DE ANIMAÇÕES
# ==============================================================================
func _atualizarAnimacoes() -> void:
	if is_on_floor() and estavaNoAr:
		estaPousando = true
		animSprite.play("land")

	estavaNoAr = not is_on_floor()
	
	if estaAtacando:
		return

	if not is_on_floor():
		_atualizarAnimacoesAereas()
	else:
		_atualizarAnimacoesTerrestres()

func _atualizarAnimacoesAereas() -> void:
	if velocity.y < 0:
		animSprite.play("jump")
	else:
		animSprite.play("fall")

func _atualizarAnimacoesTerrestres() -> void:
	if estaPousando:
		if velocity.x != 0:
			estaPousando = false
			animSprite.play("walk")
		return
		
	if velocity.x != 0:
		animSprite.play("walk")
	else:
		animSprite.play("idle")

func _aoTerminarAnimacaoSprite() -> void:
	if animSprite.animation == "land":
		estaPousando = false

# ==============================================================================
# INTERFACE E FUNÇÕES AUXILIARES
# ==============================================================================
func _configurarInterface() -> void:
	atualizarVidas(GameManager.vidas)
	
	if hudNomeFase:
		hudNomeFase.text = nomeFase
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(hudNomeFase):
			var interpolacao = get_tree().create_tween()
			interpolacao.tween_property(hudNomeFase, "modulate:a", 0.0, 1.5)

func atualizarVidas(qtd: int) -> void:
	if hudVidas:
		hudVidas.text = "Vidas: " + str(qtd)

func definirPosicaoNascimento(posicao: Vector2) -> void:
	posicaoNascimento = posicao
	global_position = posicaoNascimento

func reiniciarNaPosicaoNascimento() -> void:
	global_position = posicaoNascimento
	velocity = Vector2.ZERO

func _tocarSomSeguro(nomeSom: String, variarPitch: bool = false) -> void:
	if AudioManager.has_method("tocarSom"):
		AudioManager.tocarSom(nomeSom, variarPitch)
