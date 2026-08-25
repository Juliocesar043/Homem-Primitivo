extends StaticBody2D

@export var arvore_queimada: Sprite2D
@export var arvore_normal: Sprite2D
@export var anim_fogo: AnimatedSprite2D
@export var colisao_dano: CollisionShape2D

func _on_zona_dano_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		GameManager.perder_vida()

func _on_zona_dano_area_entered(area: Area2D) -> void:
	if area.is_in_group("ataque"):
		_apagar_fogo()

func _apagar_fogo() -> void:
	if anim_fogo:
		anim_fogo.visible = false
	if arvore_queimada:
		arvore_queimada.visible = false
	if arvore_normal:
		arvore_normal.visible = true
	if colisao_dano:
		colisao_dano.set_deferred("disabled", true)
