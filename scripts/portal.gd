extends Area2D

@export_file("*.tscn") var proximaCena: String 

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	if proximaCena != "":
		get_tree().call_deferred("change_scene_to_file", proximaCena)
	else:
		push_error("ERRO: Caminho da cena não definido no Inspetor do Portal!")
