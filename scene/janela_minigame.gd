extends Control

signal concluido

func alternarJanela() -> void:
	if visible:
		ocultarJanela()
	else:
		mostrarJanela()

func mostrarJanela() -> void:
	show()

func ocultarJanela() -> void:
	hide()
