extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast = $RayCast2D 

var was_in_air: bool = false
var is_landing: bool = false
var is_interacting: bool = false
var estaMovendo: bool = false
var tempo_passo: float = 0.0
var intervalo_passo: float = 0.35 

const SPEED = 300.0
const JUMP_VELOCITY = -600.0



func _physics_process(delta: float) -> void:
	# Aplica a gravidade sempre
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("interagir") and is_on_floor() and not is_interacting:
		is_interacting = true
		AudioManager.tocar_som("interagir")
		
		
	# Lida com o pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		AudioManager.tocar_som("pulo", true)
		
	# Pega a direção e lida com o movimento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if is_on_floor() and velocity.x != 0:
		estaMovendo = true


	# Detecta o exato momento em que ele encosta no chão
	if is_on_floor() and was_in_air:
		is_landing = true
		anim.play("land")

	# Atualiza a variável para o próximo frame
	was_in_air = not is_on_floor()

	
	# Lógica de transição de animações padrão
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
		if is_landing:
			if velocity.x != 0:
				is_landing = false
				anim.play("walk")
			elif Input.is_anything_pressed():
					is_landing = false
					anim.play("idle") 
		else:
			if direction > 0:
				anim.flip_h = true # Dica: Geralmente direita (>) é false 
				anim.play("walk")
			elif direction < 0:
				anim.flip_h = false  # Dica: Geralmente esquerda (<) é true
				anim.play("walk")
			elif is_interacting == true:
				anim.play("interagir")
				await anim.animation_finished
				is_interacting = false
			elif not Input.is_anything_pressed() and not is_interacting:
				anim.play("idle")
