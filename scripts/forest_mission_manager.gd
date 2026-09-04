extends Node

var total_fogos = 0
var fogos_apagados = 0
var concluida = false

func _ready() -> void:
	call_deferred("_contar_fogos")

func _contar_fogos() -> void:
	var scene_root = get_tree().current_scene
	var nodes = scene_root.find_children("*", "Node", true, false)
	for n in nodes:
		if n.get_script():
			var s_path = n.get_script().resource_path
			if s_path.ends_with("arvore_fogo.gd") or s_path.ends_with("arbusto_fogo.gd"):
				total_fogos += 1
				if n.has_signal("fogo_apagado"):
					n.fogo_apagado.connect(_on_fogo_apagado)
			elif s_path.ends_with("fogo.gd"):
				total_fogos += 1
				n.tree_exiting.connect(_on_fogo_apagado)
	print("ForestManager: found ", total_fogos, " fires.")

func _on_fogo_apagado() -> void:
	fogos_apagados += 1
	if fogos_apagados >= total_fogos and not concluida:
		concluida = true
		if GameManager.has_method("completar_fase"):
			GameManager.completar_fase("floresta")
		var tela = load("res://scene/tela_conclusao.tscn").instantiate()
		get_tree().current_scene.add_child(tela)
