extends Area2D

var jogador_perto = false
@onready var minigame = $CanvasLayer/JanelaMinigame

func _ready():
	minigame.hide() # Garante que a janela inicie fechada
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if jogador_perto and (Input.is_key_pressed(KEY_E) or Input.is_action_just_pressed("ui_accept")):
		if minigame.visible:
			minigame.hide()
		else:
			minigame.show()

func _on_body_entered(body):
	if body.name.to_lower() == "player" or body.is_in_group("Jogador"):
		jogador_perto = true

func _on_body_exited(body):
	if body.name.to_lower() == "player" or body.is_in_group("Jogador"):
		jogador_perto = false
		minigame.hide()
