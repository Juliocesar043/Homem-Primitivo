extends CharacterBody2D

const velocidade: float = 300.0
const velocidadePulo: float = -600.0

@onready var spriteAnimado: AnimatedSprite2D = $AnimatedSprite2D

var estavaNoAr: bool = false
var estaPousando: bool = false
var estaInteragindo: bool = false


func _ready() -> void:
	spriteAnimado.animation_finished.connect(aoTerminarAnimacao)


func _physics_process(delta: float) -> void:
	aplicarGravidade(delta)

	var direcao := Input.get_axis("ui_left", "ui_right")
	lidarComPulo()
	lidarComInteracao()
	aplicarMovimentoHorizontal(direcao)

	move_and_slide()
	atualizarEstadoAr()
	atualizarAnimacao(direcao)


func aplicarGravidade(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func lidarComPulo() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = velocidadePulo
		AudioManager.tocar_som("pulo", true)


func lidarComInteracao() -> void:
	if (
		Input.is_action_just_pressed("interagir")
		and is_on_floor()
		and not estaInteragindo
		and not estaPousando
	):
		estaInteragindo = true
		AudioManager.tocar_som("interagir")


func aplicarMovimentoHorizontal(direcao: float) -> void:
	if direcao != 0.0:
		velocity.x = direcao * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidade)


func atualizarEstadoAr() -> void:
	var estaNoChao := is_on_floor()

	if estaNoChao and estavaNoAr:
		estaPousando = true

	estavaNoAr = not estaNoChao


func atualizarAnimacao(direcao: float) -> void:
	if not is_on_floor():
		atualizarAnimacaoNoAr(direcao)
		return

	if estaPousando:
		reproduzirAnimacao("land")
		return

	if estaInteragindo:
		reproduzirAnimacao("interagir")
		return

	if direcao != 0.0:
		atualizarDirecao(direcao)
		reproduzirAnimacao("walk")
	else:
		reproduzirAnimacao("idle")


func atualizarAnimacaoNoAr(direcao: float) -> void:
	if velocity.y < 0.0:
		reproduzirAnimacao("jump")
	else:
		reproduzirAnimacao("fall")

	if direcao != 0.0:
		atualizarDirecao(direcao)


func atualizarDirecao(direcao: float) -> void:
	spriteAnimado.flip_h = direcao > 0.0


func reproduzirAnimacao(nomeAnimacao: StringName) -> void:
	if spriteAnimado.animation != nomeAnimacao:
		spriteAnimado.play(nomeAnimacao)


func aoTerminarAnimacao() -> void:
	match spriteAnimado.animation:
		&"interagir":
			estaInteragindo = false
		&"land":
			estaPousando = false
