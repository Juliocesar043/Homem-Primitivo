extends Area2D

@onready var minigame: Control = $CanvasLayer/JanelaMinigame

var jogadorPerto := false

func _ready() -> void:
	if minigame:
		minigame.hide()
		if minigame.has_signal("concluido"):
			minigame.concluido.connect(_aoMinijogoConcluido)

	body_entered.connect(_aoJogadorEntrar)
	body_exited.connect(_aoJogadorSair)

func _process(_delta: float) -> void:
	if jogadorPerto and Input.is_action_just_pressed("interagir") and minigame:
		minigame.alternarJanela()

func _aoJogadorEntrar(body: Node2D) -> void:
	if _eJogador(body):
		jogadorPerto = true

func _aoJogadorSair(body: Node2D) -> void:
	if _eJogador(body):
		jogadorPerto = false
		if minigame:
			minigame.ocultarJanela()

func _eJogador(body: Node2D) -> bool:
	return body.name.to_lower() == "player" or body.is_in_group("Jogador")

func _aoMinijogoConcluido() -> void:
	if minigame:
		minigame.ocultarJanela()
