extends CharacterBody2D

@export var texturas_peixe: Array[Texture2D] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D # Pega a colisão

var velocidade: float = 30.0
var direcao: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("peixe")
	visible = false
	
	# Desativa o movimento e a colisão do peixe no início
	set_physics_process(false)
	if collision:
		collision.set_deferred("disabled", true)
	
	# Sorteio das Sprites
	if texturas_peixe.size() > 0:
		sprite.texture = texturas_peixe.pick_random()
	elif sprite.hframes * sprite.vframes > 1:
		var total_frames = sprite.hframes * sprite.vframes
		sprite.frame = randi() % total_frames

	if randf() > 0.5:
		inverter_direcao()

# Função chamada pelo GameManager quando a missão for concluída
func ativar() -> void:
	visible = true
	if sprite:
		sprite.visible = true
	set_physics_process(true) # Liga o movimento
	if collision:
		collision.set_deferred("disabled", false) # Liga a colisão

func _physics_process(_delta: float) -> void:
	velocity = direcao * velocidade
	move_and_slide()
	
	if is_on_wall():
		inverter_direcao()

func inverter_direcao() -> void:
	direcao = -direcao
	sprite.flip_h = (direcao == Vector2.LEFT)
	 
