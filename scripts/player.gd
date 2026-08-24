extends CharacterBody2D


@onready var nome_fase_label = $HUD/NomeFaseLabel
@export var nome_da_fase: String = "A Floresta"
@onready var vidas_label = $HUD/VidasLabel
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_ataque = $AtaqueFolha/CollisionShape2D
@onready var anim_folha = $AtaqueFolha/folha

var was_in_air: bool = false
var is_landing: bool = false

# NOVAS VARIÁVEIS PARA O DANO
var invulneravel: bool = false
var tomando_dano: bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

func _physics_process(delta: float) -> void:
	# 1. Aplica a gravidade sempre
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. SE ESTIVER TOMANDO DANO, IGNORA OS CONTROLES E SÓ É EMPURRADO
	if tomando_dano:
		move_and_slide()
		return # O "return" faz o código parar aqui e ignorar as setas do teclado

	# --- CONTROLES NORMAIS ABAIXO ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("atacar"):
		realizar_ataque()

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction < 0: 
		anim.flip_h = true
		$AtaqueFolha.scale.x = -1 
	elif direction > 0: 
		anim.flip_h = false
		$AtaqueFolha.scale.x = 1 
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animações
	if is_on_floor() and was_in_air:
		is_landing = true
		anim.play("land")

	was_in_air = not is_on_floor()

	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump") 
		else:
			anim.play("fall") 
	else:
		if is_landing:
			if velocity.x != 0:
				is_landing = false
				anim.play("walk") 
		else:
			if direction != 0: 
				anim.play("walk")
			else:
				if anim.animation != "atacar":
					anim.play("idle")

func realizar_ataque():
	hitbox_ataque.disabled = false 
	if anim_folha: anim_folha.visible = true
	anim.play("atacar")
	
	if anim_folha: anim_folha.rotation_degrees = -30 
	var tween = get_tree().create_tween()
	if anim_folha: tween.tween_property(anim_folha, "rotation_degrees", 100, 0.2) 
	
	await get_tree().create_timer(0.3).timeout 
	
	hitbox_ataque.disabled = true 
	if anim_folha: 
		anim_folha.visible = false
		anim_folha.rotation_degrees = 0

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "land":
		is_landing = false
	elif anim.animation == "atacar":
		anim.play("idle")

# FUNÇÃO DO DANO ATUALIZADA (COM EMPURRÃO E PROTEÇÃO)
func receber_dano():
	invulneravel = true
	tomando_dano = true
	
	# O Empurrão (Knockback)
	velocity.y = -350 # Joga pra cima
	if anim.flip_h:
		velocity.x = 350 # Se olha pra esquerda, joga pra direita
	else:
		velocity.x = -350 # Se olha pra direita, joga pra esquerda
		
	anim.modulate = Color(1, 0, 0) # Fica vermelho
	
	# Tempo que o jogador fica paralisado voando para trás (0.3 segundos)
	await get_tree().create_timer(0.3).timeout
	tomando_dano = false
	
	# Fica com a imagem meio transparente (Efeito de invulnerabilidade)
	anim.modulate = Color(1, 1, 1, 0.5)
	
	# Tempo total de proteção sem tomar dano (1 segundo)
	await get_tree().create_timer(1.0).timeout
	
	# Fim da proteção
	anim.modulate = Color(1, 1, 1, 1) # Volta ao normal
	invulneravel = false
	
func _ready() -> void:
	atualizar_vidas(GameManager.vidas)
	
	# Define o nome da fase e faz desaparecer suavemente
	if nome_fase_label:
		nome_fase_label.text = nome_da_fase
		await get_tree().create_timer(2.0).timeout
		
		var tween = get_tree().create_tween()
		tween.tween_property(nome_fase_label, "modulate:a", 0.0, 1.5)
		
# Atualiza o texto na tela
func atualizar_vidas(qtd):
	if vidas_label:
		vidas_label.text = "Vidas: " + str(qtd)
