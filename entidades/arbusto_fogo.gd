extends StaticBody2D

@export var arbustoQueimando: AnimatedSprite2D
@export var arbustoNormal: Sprite2D
@export var colisaoDano: CollisionShape2D


signal fogo_apagado
var apagado = false


func _on_zona_dano_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		GameManager.perderVida()

func _on_zona_dano_area_entered(area: Area2D) -> void:
	if area.is_in_group("ataque"):
		_apagarFogo()

func _apagarFogo() -> void:
	
	if apagado: return
	apagado = true
	fogo_apagado.emit()
	if arbustoQueimando:
		arbustoQueimando.visible = false
	if arbustoNormal:
		arbustoNormal.visible = true
	if colisaoDano:
		colisaoDano.set_deferred("disabled", true)
