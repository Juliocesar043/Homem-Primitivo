extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

# --- VARIÁVEIS DE ESTADO (MOVIMENTO) ---
var was_in_air: bool = false
var is_landing: bool = false
var is_swimming: bool = false
var swim_time: float = 0.0

const SPEED = 300.0
const SWIM_SPEED = 180.0
const JUMP_VELOCITY = -600.0

func _get_movement_input() -> Vector2:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		input_dir.x = -1.0
	elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		input_dir.x = 1.0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		input_dir.y = -1.0
	elif Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		input_dir.y = 1.0
	return input_dir.normalized()

# --- VARIÁVEIS DE ESTADO (ITENS E NPC) ---
enum Item { NONE, TRASH_BAG, FISH_FOOD }
var equipped_item: Item = Item.NONE
var ferramentas_desbloqueadas: bool = true

# Aviso que será enviado ao HUD quando trocar de item
signal item_changed(new_item: Item)

func _ready() -> void:
	# Coloca o jogador no grupo "player" via código (caso não tenha feito pelo painel)
	add_to_group("player")
	
	# --- CONEXÃO COM A HUD ---
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		item_changed.connect(hud._on_player_item_changed)
		# Envia o item atual para a HUD assim que o jogo começa
		item_changed.emit(equipped_item)
	
	
	if camera:
		camera.make_current()
		camera.limit_bottom = 721
		camera.limit_top = -483
		camera.limit_right = 5202
		camera.limit_left = -4

# --- SISTEMA DE TROCA DE ITENS (Teclas 1 e 2) ---
var jump_requested: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			equipped_item = Item.TRASH_BAG
			item_changed.emit(equipped_item)
		elif event.keycode == KEY_2:
			equipped_item = Item.FISH_FOOD
			item_changed.emit(equipped_item)
		elif event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE:
			jump_requested = true

func _physics_process(delta: float) -> void:
	if is_swimming:
		_processar_nado(delta)
	else:
		_processar_terra(delta)

	move_and_slide()

# --- LÓGICA DE NADO ---
func _processar_nado(delta: float) -> void:
	swim_time += delta
	var input_dir := _get_movement_input()
	var target_velocity = input_dir * SWIM_SPEED
	velocity = velocity.move_toward(target_velocity, 12.0)

	if velocity.length() > 30:
		anim.play("jump")
	else:
		anim.play("fall")

	if input_dir != Vector2.ZERO:
		var target_angle = input_dir.y * 0.35
		if anim.flip_h:
			target_angle *= -1.0
		rotation = lerp_angle(rotation, target_angle, 0.1)
	else:
		rotation = lerp_angle(rotation, 0.0, 0.1)
		velocity.y = sin(swim_time * 4.0) * 20.0 

	if input_dir.x > 0:
		anim.flip_h = true
	elif input_dir.x < 0:
		anim.flip_h = false

	modulate = Color(0.7, 0.9, 1.0, 0.85)

# --- LÓGICA DE TERRA ---
func _processar_terra(delta: float) -> void:
	modulate = Color.WHITE
	rotation = lerp_angle(rotation, 0.0, 0.2)
	swim_time = 0.0

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto: Espaco, mantendo W e seta para cima como pulo no solo.
	if is_on_floor():
		if jump_requested or Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
		jump_requested = false
	else:
		jump_requested = false

	var direction := _get_movement_input().x
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	_processar_animacoes_terra(direction)

func _processar_animacoes_terra(direction: float) -> void:
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

func _on_area_agua_body_entered(body: Node2D) -> void:
	if body == self:
		is_swimming = true

func _on_area_agua_body_exited(body: Node2D) -> void:
	if body == self:
		is_swimming = false
