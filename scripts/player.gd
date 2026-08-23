extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var estavaNoAr: bool = false
var estaPousando: bool = false
var estaInteragindo: bool = false

var posicaoNascimento: Vector2 = Vector2(97.0, -32.0)
var limitesSala: Rect2 = Rect2(0, -1800, 15000, 2600)

const VELOCIDADE = 300.0
const VELOCIDADE_PULO = -600.0

func _ready() -> void:
	global_position = posicaoNascimento
	camera.position = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("interagir") and is_on_floor() and not estaInteragindo:
		estaInteragindo = true
		AudioManager.tocarSom("interagir")

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = VELOCIDADE_PULO
		AudioManager.tocarSom("pulo", true)

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * VELOCIDADE
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)

	move_and_slide()

	if global_position.y > 420.0:
		reiniciarNaPosicaoNascimento()

	if is_on_floor() and estavaNoAr:
		estaPousando = true
		anim.play("land")

	estavaNoAr = not is_on_floor()

	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
			if direction > 0:
				anim.flip_h = true
			elif direction < 0:
				anim.flip_h = false
		else:
			anim.play("fall")
			if direction > 0:
				anim.flip_h = true
			elif direction < 0:
				anim.flip_h = false
	else:
		if estaPousando:
			if velocity.x != 0:
				estaPousando = false
				anim.play("walk")
			elif Input.is_anything_pressed():
				estaPousando = false
				anim.play("idle")
		else:
			if estaInteragindo:
				anim.play("interagir")
				await anim.animation_finished
				estaInteragindo = false
			elif direction > 0:
				anim.flip_h = true
				anim.play("walk")
			elif direction < 0:
				anim.flip_h = false
				anim.play("walk")
			elif not Input.is_anything_pressed() and not estaInteragindo:
				anim.play("idle")


func definirPosicaoNascimento(posicao: Vector2) -> void:
	posicaoNascimento = posicao
	global_position = posicaoNascimento


func reiniciarNaPosicaoNascimento() -> void:
	global_position = posicaoNascimento
	velocity = Vector2.ZERO
