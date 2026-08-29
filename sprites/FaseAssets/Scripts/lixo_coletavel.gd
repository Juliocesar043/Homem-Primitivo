extends Area2D

signal removido

@onready var sprite: Sprite2D = $Sprite2D

var _removido: bool = false
var _jogador_dentro: Node2D = null

const ITEM_CORRETO: int = 1  # Item.TRASH_BAG

func _ready() -> void:
	add_to_group("lixo")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	# Calcula quantas variacoes existem na imagem (colunas x linhas)
	var total_frames = sprite.hframes * sprite.vframes
	
	# Sorteia um quadro aleatorio
	if total_frames > 0:
		sprite.frame = randi() % total_frames

# Coleta apenas com o Player usando o item correto (tecla 1 = TRASH_BAG).
# A coleta e revalidada quando o item muda enquanto o player segue dentro da area.
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_jogador_dentro = body
	if not body.is_connected("item_changed", _on_player_item_changed):
		body.connect("item_changed", _on_player_item_changed)
	_tentar_coletar(body)

func _on_body_exited(body: Node2D) -> void:
	if body != _jogador_dentro:
		return
	if body.is_connected("item_changed", _on_player_item_changed):
		body.disconnect("item_changed", _on_player_item_changed)
	_jogador_dentro = null

func _on_player_item_changed(_new_item: int) -> void:
	if _jogador_dentro != null:
		_tentar_coletar(_jogador_dentro)

func _tentar_coletar(body: Node2D) -> void:
	if _removido:
		return
	if body.get("equipped_item") != ITEM_CORRETO:
		return
	var manager = get_tree().get_first_node_in_group("game_manager")
	if manager and manager.has_method("missao_em_andamento") and not manager.missao_em_andamento():
		return
	_removido = true
	removido.emit()
	if manager and manager.has_method("notificar_lixo_removido"):
		manager.notificar_lixo_removido()
	queue_free()
