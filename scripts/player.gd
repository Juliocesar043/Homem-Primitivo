extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var somPulo: AudioStreamPlayer2D = $AudioStreamPlayer2D

var was_in_air: bool = false
var is_landing: bool = false
const SPEED = 300.0
const JUMP_VELOCITY = -600.0

func _physics_process(delta: float) -> void:
	# Aplica a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Lida com o pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		somPulo.play()
		

	# Pega a direção e lida com o movimento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	move_and_slide()

	# 1. Detecta o exato momento em que ele encosta no chão
	if is_on_floor() and was_in_air:
		is_landing = true
		anim.play("land")

	# 2. Atualiza a variável para o próximo frame
	was_in_air = not is_on_floor()

	# 3. Lógica de transição de animações
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
			if direction > 0:
				anim.flip_h = true 
				anim.play("walk")
			elif direction < 0:
				anim.flip_h = false 
				anim.play("walk")
			else:
				anim.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "land":
		is_landing = false
