extends Area2D

@onready var sprite_fundo = $PinturaFundo
@onready var sprite_floresta = $PinturaFloresta
@onready var sprite_lago = $PinturaLago
@onready var sprite_vila = $PinturaVila
@onready var sprite_completa = $PinturaCompleta

var jogador_perto = false
var _pintura_finalizada = false

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
	
	# Se todas as fases foram pintadas agora, iniciar sequência de finalização
	if completou_todas_agora and not _pintura_finalizada:
		_pintura_finalizada = true
		_iniciar_sequencia_finalizacao()

func _iniciar_sequencia_finalizacao() -> void:
	print("Pintura completa! Iniciando sequência de finalização...")
	
	# Desativar controle do jogador via pausa de processo (opcional: se quiser travar input)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
		player.set_process(false)
	
	# Criar CanvasLayer para overlay
	var overlay_layer = CanvasLayer.new()
	overlay_layer.layer = 100
	get_tree().current_scene.add_child(overlay_layer)
	
	# Criar ColorRect preto para efeito de "olho piscando"
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)  # Começa transparente
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_layer.add_child(overlay)
	
	# --- Animação de "olho piscando" (3 piscadas) ---
	var tween = get_tree().create_tween()
	# Piscada 1
	tween.tween_property(overlay, "color:a", 1.0, 0.3)
	tween.tween_interval(0.2)
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	tween.tween_interval(0.3)
	# Piscada 2
	tween.tween_property(overlay, "color:a", 1.0, 0.3)
	tween.tween_interval(0.2)
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	tween.tween_interval(0.3)
	# Piscada 3 - fica fechado
	tween.tween_property(overlay, "color:a", 1.0, 0.4)
	tween.tween_interval(0.5)
	
	await tween.finished
	
	# --- Mostrar botão "Acordar" ---
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # Bloquear cliques no fundo
	
	var btn_acordar = Button.new()
	btn_acordar.text = "Acordar"
	btn_acordar.custom_minimum_size = Vector2(200, 60)
	btn_acordar.add_theme_font_size_override("font_size", 24)
	
	# Centralizar o botão
	btn_acordar.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	btn_acordar.pressed.connect(_on_acordar_pressed.bind(player))
	
	overlay_layer.add_child(btn_acordar)

func _on_acordar_pressed(player: Node) -> void:
	print("Acordar! Finalizando run e voltando ao menu...")
	
	# Registrar o tempo da run
	GameManager.finalizar_run()
	
	# Resetar o estado do jogo (fases, pinturas, vidas)
	GameManager.resetar_jogo()
	
	# Iniciar uma nova run (já que o loop recomeça)
	GameManager.iniciar_run()
	
	# Restaurar processamento do jogador (para evitar problemas ao carregar nova cena)
	if player and is_instance_valid(player):
		player.set_physics_process(true)
		player.set_process(true)
	
	# Voltar para o centro da caverna em vez do menu
	get_tree().change_scene_to_file("res://scene/caverna.tscn")
