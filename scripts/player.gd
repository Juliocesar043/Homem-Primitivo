extends CharacterBody2D

# ==============================================================================
# CONSTANTES
# ==============================================================================
const VELOCIDADE_MOVIMENTO: float = 300.0
const FORCA_PULO: float = -600.0
const FORCA_KNOCKBACK: float = 350.0
const LIMITE_QUEDA_Y: float = 1000.0

# ==============================================================================
# REFERÊNCIAS DE NÓS
# ==============================================================================
@onready var hud_nome_fase: Label = $HUD/NomeFaseLabel
@onready var hud_vidas: Label = $HUD/VidasLabel
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_ataque: CollisionShape2D = $AtaqueFolha/CollisionShape2D
@onready var anim_folha: AnimatedSprite2D = $AtaqueFolha/folha
@onready var camera = $Camera2D

# ==============================================================================
# VARIÁVEIS DE ESTADO
# ==============================================================================
@export var nome_da_fase: String = "A Floresta"

var estava_no_ar: bool = false
var esta_pousando: bool = false
var esta_atacando: bool = false
var esta_tomando_dano: bool = false
var esta_invulneravel: bool = false
var posicao_nascimento: Vector2 = Vector2.ZERO

# ==============================================================================
# FUNÇÕES PRINCIPAIS
# ==============================================================================
func _ready() -> void:
	_configurar_interface()
	camera.limit_left = -10000000
	camera.limit_top = -10000000
	camera.limit_right = 10000000
	camera.limit_bottom = 10000000

func _physics_process(delta: float) -> void:
	_aplicar_gravidade(delta)
	
	if esta_tomando_dano:
		move_and_slide()
		return
	
	_processar_entradas_de_acao()
	_processar_movimento()
	
	move_and_slide()
	
	_verificar_limites_do_mapa()
	_atualizar_animacoes()

# ==============================================================================
# LÓGICA DE MOVIMENTAÇÃO E FÍSICA
# ==============================================================================
func _aplicar_gravidade(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _processar_movimento() -> void:
	var direcao := Input.get_axis("ui_left", "ui_right")
	
	if direcao != 0:
		_virar_personagem(direcao)
		velocity.x = direcao * VELOCIDADE_MOVIMENTO
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE_MOVIMENTO)

func _virar_personagem(direcao: float) -> void:
	if direcao < 0:
		anim_sprite.flip_h = true
		if has_node("AtaqueFolha"):
			$AtaqueFolha.scale.x = -1
	elif direcao > 0:
		anim_sprite.flip_h = false
		if has_node("AtaqueFolha"):
			$AtaqueFolha.scale.x = 1

func _verificar_limites_do_mapa() -> void:
	if global_position.y > LIMITE_QUEDA_Y and posicao_nascimento != Vector2.ZERO:
		reiniciarNaPosicaoNascimento()

# ==============================================================================
# LÓGICA DE AÇÕES
# ==============================================================================
func _processar_entradas_de_acao() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_pular()
		
	if Input.is_action_just_pressed("atacar") and not esta_atacando:
		_atacar()
		
	if Input.is_action_just_pressed("interagir") and is_on_floor():
		_interagir()

func _pular() -> void:
	velocity.y = FORCA_PULO
	_tocar_som_seguro("pulo", true)

func _interagir() -> void:
	# A interação agora apenas emite o som, sem travar o movimento ou rodar animação
	_tocar_som_seguro("interagir")

func _atacar() -> void:
	esta_atacando = true
	
	if hitbox_ataque:
		hitbox_ataque.disabled = false
	
	if anim_folha:
		anim_folha.visible = true
		anim_folha.rotation_degrees = -30
		var tween = get_tree().create_tween()
		tween.tween_property(anim_folha, "rotation_degrees", 100, 0.2)
	
	anim_sprite.play("atacar")
	_tocar_som_seguro("atacar")
	
	await get_tree().create_timer(0.3).timeout
	
	if hitbox_ataque:
		hitbox_ataque.disabled = true
		
	if anim_folha:
		anim_folha.visible = false
		anim_folha.rotation_degrees = 0
		
	esta_atacando = false

# ==============================================================================
# SISTEMA DE DANO
# ==============================================================================
func pode_receber_dano() -> bool:
	return not esta_invulneravel

func receber_dano() -> void:
	if esta_invulneravel:
		return
		
	esta_invulneravel = true
	esta_tomando_dano = true
	
	_aplicar_knockback()
	
	anim_sprite.modulate = Color(1, 0, 0) # Cor de dano (Vermelho)
	_tocar_som_seguro("dano")
	await get_tree().create_timer(0.3).timeout
	
	esta_tomando_dano = false
	anim_sprite.modulate = Color(1, 1, 1, 0.5) # Efeito de invulnerabilidade (Transparente)
	
	await get_tree().create_timer(1.0).timeout
	
	anim_sprite.modulate = Color(1, 1, 1, 1) # Retorna cor ao normal
	esta_invulneravel = false

func _aplicar_knockback() -> void:
	velocity.y = -FORCA_KNOCKBACK
	if anim_sprite.flip_h:
		velocity.x = FORCA_KNOCKBACK
	else:
		velocity.x = -FORCA_KNOCKBACK

# ==============================================================================
# LÓGICA DE ANIMAÇÕES
# ==============================================================================
func _atualizar_animacoes() -> void:
	if is_on_floor() and estava_no_ar:
		esta_pousando = true
		anim_sprite.play("land")

	estava_no_ar = not is_on_floor()
	
	if esta_atacando:
		return # A animação de ataque é prioridade e dura seu próprio tempo

	if not is_on_floor():
		_atualizar_animacoes_aereas()
	else:
		_atualizar_animacoes_terrestres()

func _atualizar_animacoes_aereas() -> void:
	if velocity.y < 0:
		anim_sprite.play("jump")
	else:
		anim_sprite.play("fall")

func _atualizar_animacoes_terrestres() -> void:
	if esta_pousando:
		if velocity.x != 0:
			esta_pousando = false
			anim_sprite.play("walk")
		return
		
	if velocity.x != 0:
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_sprite.animation == "land":
		esta_pousando = false

# ==============================================================================
# INTERFACE E FUNÇÕES AUXILIARES
# ==============================================================================
func _configurar_interface() -> void:
	atualizar_vidas(GameManager.vidas)
	
	if hud_nome_fase:
		hud_nome_fase.text = nome_da_fase
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(hud_nome_fase):
			var tween = get_tree().create_tween()
			tween.tween_property(hud_nome_fase, "modulate:a", 0.0, 1.5)

func atualizar_vidas(qtd: int) -> void:
	if hud_vidas:
		hud_vidas.text = "Vidas: " + str(qtd)

func definirPosicaoNascimento(posicao: Vector2) -> void:
	posicao_nascimento = posicao
	global_position = posicao_nascimento

func reiniciarNaPosicaoNascimento() -> void:
	global_position = posicao_nascimento
	velocity = Vector2.ZERO

func _tocar_som_seguro(nome_som: String, variar_pitch: bool = false) -> void:
	if AudioManager.has_method("tocar_som"):
		AudioManager.tocar_som(nome_som, variar_pitch)
