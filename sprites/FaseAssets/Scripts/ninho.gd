extends Area2D

signal removido

var _removido: bool = false
var _jogador_dentro: Node2D = null

const ITEM_CORRETO: int = 2  # Item.FISH_FOOD

func _ready() -> void:
	add_to_group("ninho")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

# Coleta apenas com o Player usando o item correto (tecla 2 = FISH_FOOD).
# A coleta e revalidada quando o item muda enquanto o player segue dentro da area.
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_jogador_dentro = body
	if body.has_signal("itemAlterado") and not body.is_connected("itemAlterado", _on_player_item_changed):
		body.connect("itemAlterado", _on_player_item_changed)
	_tentar_coletar(body)

func _on_body_exited(body: Node2D) -> void:
	if body != _jogador_dentro:
		return
	if body.has_signal("itemAlterado") and body.is_connected("itemAlterado", _on_player_item_changed):
		body.disconnect("itemAlterado", _on_player_item_changed)
	_jogador_dentro = null

func _on_player_item_changed(_new_item: int) -> void:
	if _jogador_dentro != null:
		_tentar_coletar(_jogador_dentro)

func _tentar_coletar(body: Node2D) -> void:
	if _removido:
		return
	if body.get("itemEquipado") != ITEM_CORRETO:
		return
	var manager = get_tree().get_first_node_in_group("game_manager")
	if manager and manager.has_method("missao_em_andamento") and not manager.missao_em_andamento():
		return
	_removido = true
	removido.emit()
	if manager and manager.has_method("notificar_ninho_removido"):
		manager.notificar_ninho_removido()
	queue_free()
