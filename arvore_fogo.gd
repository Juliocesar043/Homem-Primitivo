extends StaticBody2D

@export var arvoreQueimada: Sprite2D
@export var arvoreNormal: Sprite2D
@export var animFogo: AnimatedSprite2D
@export var colisaoDano: CollisionShape2D

func _on_zona_dano_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		GameManager.perderVida()

func _on_zona_dano_area_entered(area: Area2D) -> void:
	if area.is_in_group("ataque"):
		_apagarFogo()

func _apagarFogo() -> void:
	if animFogo:
		animFogo.visible = false
	if arvoreQueimada:
		arvoreQueimada.visible = false
	if arvoreNormal:
		arvoreNormal.visible = true
	if colisaoDano:
		colisaoDano.set_deferred("disabled", true)
