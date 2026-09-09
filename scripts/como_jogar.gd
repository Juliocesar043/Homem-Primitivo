extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = get_viewport_rect().size

	$CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	$CenterContainer.size = size

	# Mantem apenas os comandos essenciais para caber na resolucao do jogo.
	$CenterContainer/PanelContainer/MainVBox/ScrollContainer/ContentVBox/Intro.hide()
	$CenterContainer/PanelContainer/MainVBox/ScrollContainer/ContentVBox/Label1.hide()
	$CenterContainer/PanelContainer/MainVBox/ScrollContainer/ContentVBox/Label2.hide()
	$CenterContainer/PanelContainer/MainVBox/ScrollContainer/ContentVBox/TipLabel.hide()
	for spacer in $CenterContainer/PanelContainer/MainVBox/ScrollContainer/ContentVBox.get_children():
		if spacer is Control and spacer.name.begins_with("Spacer"):
			spacer.hide()

	await get_tree().process_frame
	var panel := $CenterContainer/PanelContainer
	panel.position = (size - panel.size) / 2.0
	$CenterContainer/PanelContainer/MainVBox/ScrollContainer.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

func _on_close_button_pressed() -> void:
	queue_free()

func _input(event: InputEvent) -> void:
	# Fechar ao pressionar ESC
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_close_button_pressed()
		get_tree().root.set_input_as_handled()
