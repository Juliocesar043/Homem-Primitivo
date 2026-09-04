extends Area2D

@onready var sprite_fundo = $PinturaFundo
@onready var sprite_floresta = $PinturaFloresta
@onready var sprite_lago = $PinturaLago
@onready var sprite_vila = $PinturaVila
@onready var sprite_completa = $PinturaCompleta

var jogador_perto = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	atualizar_pinturas(false)

func _process(_delta: float) -> void:
	if jogador_perto and Input.is_action_just_pressed("interagir"):
		pintar_novas_fases()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower() == "player":
		jogador_perto = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower() == "player":
		jogador_perto = false

func atualizar_pinturas(animar: bool = false) -> void:
	var todas = true
	
	if GameManager.fases_pintadas["floresta"]:
		sprite_floresta.visible = true
	else:
		todas = false
		sprite_floresta.visible = false
		
	if GameManager.fases_pintadas["lago"]:
		sprite_lago.visible = true
	else:
		todas = false
		sprite_lago.visible = false
		
	if GameManager.fases_pintadas["vila"]:
		sprite_vila.visible = true
	else:
		todas = false
		sprite_vila.visible = false
		
	sprite_completa.visible = todas
	if todas:
		# Se estiver completa, ocultar as partes individuais (ja que a completa cobre tudo)
		sprite_floresta.visible = false
		sprite_lago.visible = false
		sprite_vila.visible = false

func pintar_novas_fases() -> void:
	var pintou_algo = false
	var completou_todas_agora = true
	
	for fase in GameManager.fases_concluidas.keys():
		if GameManager.fases_concluidas[fase] and not GameManager.fases_pintadas[fase]:
			GameManager.fases_pintadas[fase] = true
			pintou_algo = true
			
		if not GameManager.fases_pintadas[fase]:
			completou_todas_agora = false
			
	if pintou_algo:
		print("Nova parte da pintura revelada!")
		atualizar_pinturas(true)
